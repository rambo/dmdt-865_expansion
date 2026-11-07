#define UART_TEST
#include "../app/src/main/cpp/uart.c"
#include <assert.h>
#include <stdlib.h>

int main(void) {
    assert(send_frame() == -1 && errno == EBADF);
    assert(open_uart("/does-not-exist/t865-uart") == -1 && errno == ENOENT);
    char file[] = "/tmp/t865-uart-XXXXXX";
    int regular = mkstemp(file);
    assert(regular >= 0);
    assert(open_uart(file) == -1 && errno == ENODEV);
    assert(close(regular) == 0 && unlink(file) == 0);
    assert(open_uart("/dev/null") == -1 && (errno == ENOTTY || errno == ENODEV));

    int master = posix_openpt(O_RDWR | O_NOCTTY | O_NONBLOCK);
    assert(master >= 0 && grantpt(master) == 0 && unlockpt(master) == 0);
    const char *path = ptsname(master);
    assert(path);
    int observer = open(path, O_RDWR | O_NOCTTY | O_NONBLOCK);
    assert(observer >= 0);
    struct termios before, during, after;
    assert(tcgetattr(observer, &before) == 0);
    before.c_lflag |= ICANON | ECHO;
    before.c_iflag |= IXON | IXOFF | IXANY;
    assert(cfsetispeed(&before, B19200) == 0 && cfsetospeed(&before, B19200) == 0);
    assert(tcsetattr(observer, TCSANOW, &before) == 0);
    assert(tcgetattr(observer, &before) == 0);
    assert(open_uart(path) == 0);
    int fd = active_fd;
    assert(open_uart(path) == -1 && errno == EBUSY && active_fd == fd);
    assert(fcntl(fd, F_GETFL) & O_NONBLOCK);
    assert(fcntl(fd, F_GETFD) & FD_CLOEXEC);
    assert(tcgetattr(observer, &during) == 0);
    assert(cfgetispeed(&during) == B9600 && cfgetospeed(&during) == B9600);
    assert((during.c_cflag & CSIZE) == CS8);
    assert(!(during.c_cflag & (PARENB | CSTOPB | CRTSCTS | HUPCL)));
    assert(!(during.c_iflag & (IXON | IXOFF | IXANY)));
    assert(!(during.c_lflag & (ICANON | ECHO)));
    assert(!(during.c_oflag & OPOST));
    assert(send_frame() == (int)sizeof(frame) - 1);
    char received[sizeof(frame)] = {0};
    size_t used = 0;
    while (used < sizeof(frame) - 1) {
        struct pollfd pfd = { .fd = master, .events = POLLIN };
        assert(poll(&pfd, 1, 1000) == 1);
        ssize_t n = read(master, received + used, sizeof(frame) - 1 - used);
        assert(n > 0);
        used += (size_t)n;
    }
    assert(memcmp(frame, received, sizeof(frame) - 1) == 0);
    // A stalled receiver must time out rather than hang Stop indefinitely.
    char fill[4096];
    memset(fill, 'U', sizeof(fill));
    size_t queued = 0;
    for (;;) {
        ssize_t n = write(fd, fill, sizeof(fill));
        if (n < 0) { assert(errno == EAGAIN); break; }
        assert(n > 0);
        queued += (size_t)n;
        assert(queued < 16 * 1024 * 1024);
    }
    long long started = milliseconds();
    assert(send_frame() == -1 && errno == ETIMEDOUT);
    assert(milliseconds() - started < 2000);
    assert(close_uart() == 0 && active_fd == -1);
    assert(fcntl(fd, F_GETFD) == -1 && errno == EBADF);
    assert(tcgetattr(observer, &after) == 0);
    assert(before.c_iflag == after.c_iflag && before.c_oflag == after.c_oflag);
    assert(before.c_cflag == after.c_cflag);
    // The kernel may mark queued input for reprocessing when canonical mode returns.
    assert((before.c_lflag & ~PENDIN) == (after.c_lflag & ~PENDIN));
    assert(cfgetispeed(&after) == B19200 && cfgetospeed(&after) == B19200);
    assert(memcmp(before.c_cc, after.c_cc, sizeof(before.c_cc)) == 0);
    assert(close_uart() == 0);
    close(observer);
    close(master);
    puts("PASS: real PTY bytes, raw 9600/8N1, errors, timeout, and termios restoration");
}
