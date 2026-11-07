#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>
#ifndef UART_TEST
#include <jni.h>
#endif

static int active_fd = -1;
static struct termios original;
static const char frame[] = "UUUU T865 UART WK2\r\n";

/* Called on one worker; a normal stop restores the original termios settings. */
static int open_uart(const char *path) {
    if (active_fd >= 0) { errno = EBUSY; return -1; }
    int fd = open(path, O_RDWR | O_NONBLOCK | O_NOCTTY | O_CLOEXEC | O_NOFOLLOW);
    if (fd < 0) return -1;
    struct stat st;
    if (fstat(fd, &st) < 0) goto fail;
    if (!S_ISCHR(st.st_mode)) { errno = ENODEV; goto fail; }
    if (tcgetattr(fd, &original) < 0) goto fail;
    struct termios config = original;
    cfmakeraw(&config);
    config.c_iflag &= ~(IXON | IXOFF | IXANY);
    config.c_cflag &= ~(CSIZE | PARENB | CSTOPB | CRTSCTS | HUPCL);
    config.c_cflag |= CS8 | CLOCAL | CREAD;
    config.c_cc[VMIN] = 0;
    config.c_cc[VTIME] = 0;
    if (cfsetispeed(&config, B9600) < 0 || cfsetospeed(&config, B9600) < 0) goto fail;
    if (tcsetattr(fd, TCSANOW, &config) < 0) {
        int error = errno;
        (void)tcsetattr(fd, TCSANOW, &original);
        errno = error;
        goto fail;
    }
    active_fd = fd;
    return 0;
fail: {
    int error = errno;
    (void)close(fd);
    errno = error;
    return -1;
}}

static long long milliseconds(void) {
    struct timespec now;
    if (clock_gettime(CLOCK_MONOTONIC, &now) < 0) return -1;
    return (long long)now.tv_sec * 1000 + now.tv_nsec / 1000000;
}

static int send_frame(void) {
    if (active_fd < 0) { errno = EBADF; return -1; }
    long long now = milliseconds();
    if (now < 0) return -1;
    long long deadline = now + 250;
    size_t sent = 0;
    while (sent < sizeof(frame) - 1) {
        now = milliseconds();
        if (now < 0) return -1;
        if (now >= deadline) { errno = ETIMEDOUT; return -1; }
        ssize_t n = write(active_fd, frame + sent, sizeof(frame) - 1 - sent);
        if (n > 0) { sent += (size_t)n; continue; }
        if (n == 0) { errno = EIO; return -1; }
        if (errno == EINTR) continue;
        if (errno != EAGAIN && errno != EWOULDBLOCK) return -1;
        struct pollfd pfd = { .fd = active_fd, .events = POLLOUT };
        int ready = poll(&pfd, 1, (int)(deadline - now));
        if (ready < 0) { if (errno == EINTR) continue; return -1; }
        if (ready == 0) { errno = ETIMEDOUT; return -1; }
        if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL)) { errno = EIO; return -1; }
    }
    return (int)sent;
}

static int close_uart(void) {
    if (active_fd < 0) return 0;
    int fd = active_fd;
    active_fd = -1;
    int error = tcsetattr(fd, TCSANOW, &original) < 0 ? errno : 0;
    if (close(fd) < 0 && !error) error = errno; /* Never retry close. */
    if (error) { errno = error; return -1; }
    return 0;
}

#ifndef UART_TEST
static void throw_io(JNIEnv *env, const char *operation) {
    int error = errno;
    char message[256];
    snprintf(message, sizeof(message), "%s: errno=%d (%s)", operation, error, strerror(error));
    jclass type = (*env)->FindClass(env, "java/io/IOException");
    if (type) (*env)->ThrowNew(env, type, message);
}

JNIEXPORT void JNICALL Java_dev_t865_uarttx_MainActivity_openUart(JNIEnv *env, jobject self) {
    (void)self;
    if (open_uart("/dev/ttysWK2") < 0) throw_io(env, "open/configure /dev/ttysWK2");
}

JNIEXPORT jint JNICALL Java_dev_t865_uarttx_MainActivity_sendFrame(JNIEnv *env, jobject self) {
    (void)self;
    int result = send_frame();
    if (result < 0) throw_io(env, "write /dev/ttysWK2");
    return result;
}

JNIEXPORT void JNICALL Java_dev_t865_uarttx_MainActivity_closeUart(JNIEnv *env, jobject self) {
    (void)self;
    if (close_uart() < 0) throw_io(env, "restore/close /dev/ttysWK2");
}
#endif
