#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/xattr.h>
#include <unistd.h>
#ifdef __linux__
#include <sys/sysmacros.h>
#endif
#ifndef PROBE_TEST
#include <jni.h>
#endif

enum { REPORT_CAPACITY = 131072, ENTRY_LIMIT = 256 };
typedef struct { char text[REPORT_CAPACITY]; size_t used; } Report;

static void append(Report *r, const char *format, ...) {
    if (r->used >= sizeof(r->text) - 1) return;
    va_list args;
    va_start(args, format);
    int n = vsnprintf(r->text + r->used, sizeof(r->text) - r->used, format, args);
    va_end(args);
    if (n > 0) {
        size_t remaining = sizeof(r->text) - r->used;
        r->used += (size_t)n < remaining ? (size_t)n : remaining - 1;
    }
}

static const char *errno_name(int e) {
    switch (e) {
        case EACCES: return "EACCES";
        case EPERM: return "EPERM";
        case ENOENT: return "ENOENT";
        case ENODEV: return "ENODEV";
        case ENXIO: return "ENXIO";
        case EBUSY: return "EBUSY";
        case EIO: return "EIO";
        case EINTR: return "EINTR";
        case EAGAIN: return "EAGAIN";
        case ELOOP: return "ELOOP";
        case ENOTDIR: return "ENOTDIR";
        case ENOTSUP: return "ENOTSUP";
        case ERANGE: return "ERANGE";
        case EINVAL: return "EINVAL";
        case ENODATA: return "ENODATA";
        case EMFILE: return "EMFILE";
        case ENFILE: return "ENFILE";
        default: return "errno";
    }
}

static void failure(Report *r, const char *operation, int e) {
    append(r, "  %s: -1, errno=%d (%s: %s)\n", operation, e, errno_name(e), strerror(e));
}

/* Escape control bytes so names and metadata cannot impersonate report lines. */
static void quoted(Report *r, const char *s, size_t size) {
    for (size_t i = 0; i < size; i++) {
        unsigned char c = (unsigned char)s[i];
        if (c >= 32 && c < 127 && c != '\\') append(r, "%c", c);
        else append(r, "\\x%02x", c);
    }
}

static void label(Report *r, const char *path) {
    char value[512];
#ifdef __APPLE__
    ssize_t n = getxattr(path, "security.selinux", value, sizeof(value), 0, XATTR_NOFOLLOW);
#else
    ssize_t n = lgetxattr(path, "security.selinux", value, sizeof(value));
#endif
    if (n < 0) { failure(r, "SELinux label (lgetxattr)", errno); return; }
    while (n > 0 && value[n - 1] == '\0') n--;
    append(r, "  SELinux label: ");
    quoted(r, value, (size_t)n);
    append(r, "\n");
}

static void link_target(Report *r, const char *path) {
    char value[1024];
    ssize_t n = readlink(path, value, sizeof(value));
    if (n < 0) { failure(r, "readlink", errno); return; }
    append(r, "  link: ");
    quoted(r, value, (size_t)n);
    append(r, "%s\n", n == sizeof(value) ? " [possibly truncated]" : "");
}

/* Only these standard metadata files are read, never a /dev descriptor. */
static void read_metadata(Report *r, const char *path) {
    quoted(r, path, strlen(path));
    append(r, "\n");
    int fd = open(path, O_RDONLY | O_NONBLOCK | O_CLOEXEC);
    if (fd < 0) { failure(r, "metadata open", errno); return; }
    char value[1024];
    ssize_t n;
    do { n = read(fd, value, sizeof(value)); } while (n < 0 && errno == EINTR);
    int saved = errno;
    if (n < 0) failure(r, "metadata read", saved);
    else {
        while (n > 0 && (value[n - 1] == '\n' || value[n - 1] == '\0')) n--;
        append(r, "  value: ");
        quoted(r, value, (size_t)n);
        append(r, "%s\n", n == sizeof(value) ? " [possibly truncated]" : "");
    }
    if (close(fd) < 0) failure(r, "metadata close", errno);
}

static bool numeric_spidev(const char *name) {
    if (strncmp(name, "spidev", 6) != 0) return false;
    const char *p = name + 6;
    if (*p < '0' || *p > '9') return false;
    while (*p >= '0' && *p <= '9') p++;
    if (*p++ != '.') return false;
    if (*p < '0' || *p > '9') return false;
    while (*p >= '0' && *p <= '9') p++;
    return *p == '\0';
}

static bool allowed_device(const char *path) {
    if (strncmp(path, "/dev/ttysWK", 11) == 0 && strlen(path) == 12)
        return path[11] >= '0' && path[11] <= '3';
    return strncmp(path, "/dev/", 5) == 0 && numeric_spidev(path + 5);
}

static void device(Report *r, const char *path, bool probe) {
    append(r, "\n");
    quoted(r, path, strlen(path));
    append(r, "\n");
    struct stat st;
    int result = lstat(path, &st);
    int saved = errno;
    if (result < 0) failure(r, "lstat", saved);
    else {
        append(r, "  type=%s mode=%04o uid=%u gid=%u",
               S_ISCHR(st.st_mode) ? "character" : S_ISLNK(st.st_mode) ? "symlink" : "other",
               (unsigned)(st.st_mode & 07777), (unsigned)st.st_uid, (unsigned)st.st_gid);
        if (S_ISCHR(st.st_mode))
            append(r, " rdev=%u:%u", (unsigned)major(st.st_rdev), (unsigned)minor(st.st_rdev));
        append(r, "\n");
        if (S_ISLNK(st.st_mode)) link_target(r, path);
    }
    label(r, path);
    if (!probe) { append(r, "  device open: NOT REQUESTED (metadata only)\n"); return; }
    if (!allowed_device(path)) {
        append(r, "  device open: SKIPPED (outside fixed device allowlist)\n"); return;
    }
    if (result == 0 && !S_ISCHR(st.st_mode)) {
        append(r, "  device open: SKIPPED (not a direct character device)\n"); return;
    }
    /* No reads, writes, ioctl, termios, or retries on this descriptor. */
    int fd = open(path, O_RDONLY | O_NONBLOCK | O_NOCTTY | O_CLOEXEC | O_NOFOLLOW);
    saved = errno;
    if (fd < 0) { failure(r, "device open", saved); return; }
    append(r, "  device open: SUCCESS, errno=0 (no data/configuration calls)\n");
    /* Do not retry close: Linux may already have released the descriptor. */
    if (close(fd) < 0) failure(r, "device close", errno);
    else append(r, "  device close: SUCCESS\n");
}

static void directory(Report *r, const char *path, bool dev_nodes, bool probe) {
    append(r, "\nDirectory: %s\n", path);
    DIR *dir = opendir(path);
    if (dir == NULL) { failure(r, "opendir", errno); return; }
    size_t count = 0;
    for (;;) {
        errno = 0;
        struct dirent *entry = readdir(dir);
        if (entry == NULL) {
            if (errno != 0) failure(r, "readdir", errno);
            break;
        }
        if (entry->d_name[0] == '.') continue;
        if (dev_nodes && strncmp(entry->d_name, "spidev", 6) != 0) continue;
        if (count++ == ENTRY_LIMIT) {
            append(r, "  [listing limited to %d matching entries]\n", ENTRY_LIMIT);
            break;
        }
        char item[1024];
        int n = snprintf(item, sizeof(item), "%s/%s", path, entry->d_name);
        if (n < 0 || (size_t)n >= sizeof(item)) {
            append(r, "  [entry path too long; skipped]\n"); continue;
        }
        if (dev_nodes) device(r, item, probe);
        else {
            quoted(r, item, strlen(item));
            append(r, "\n");
            struct stat st;
            if (lstat(item, &st) < 0) failure(r, "lstat", errno);
            else if (S_ISLNK(st.st_mode)) link_target(r, item);
            char attribute[1200];
            snprintf(attribute, sizeof(attribute), "%s/driver", item);
            quoted(r, attribute, strlen(attribute));
            append(r, "\n");
            link_target(r, attribute);
            const char *names[] = { "modalias", "dev" };
            for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); i++) {
                snprintf(attribute, sizeof(attribute), "%s/%s", item, names[i]);
                read_metadata(r, attribute);
            }
        }
    }
    if (count == 0) append(r, "  (no matching entries visible to this app)\n");
    if (closedir(dir) < 0) failure(r, "closedir", errno);
}

static void collect_report(Report *r, bool probe) {
    append(r, "Process: pid=%ld uid=%ld euid=%ld gid=%ld\n",
           (long)getpid(), (long)getuid(), (long)geteuid(), (long)getgid());
    gid_t groups[128];
    int n = getgroups(128, groups);
    if (n < 0) failure(r, "getgroups", errno);
    else {
        append(r, "Supplementary gids:");
        for (int i = 0; i < n; i++) append(r, " %ld", (long)groups[i]);
        append(r, "\n");
    }
    append(r, "Mode: %s\n", probe ? "READ-ONLY OPEN/CLOSE PROBE" : "METADATA ONLY");
    append(r, "Probe flags: O_RDONLY | O_NONBLOCK | O_NOCTTY | O_CLOEXEC | O_NOFOLLOW\n");
    append(r, "No device read/write/ioctl/termios. Open/close may itself affect hardware.\n\n");
    read_metadata(r, "/proc/self/attr/current");
    read_metadata(r, "/sys/fs/selinux/enforce");
    append(r, "  enforce value 1=Enforcing, 0=Permissive; unreadable=unknown.\n");
    for (int i = 0; i < 4; i++) {
        char path[32];
        snprintf(path, sizeof(path), "/dev/ttysWK%d", i);
        device(r, path, probe);
    }
    directory(r, "/dev", true, probe);
    directory(r, "/sys/class/spi_master", false, false);
    directory(r, "/sys/bus/spi/devices", false, false);
    directory(r, "/sys/class/spidev", false, false);
    append(r, "\nInterpretation: EACCES/EPERM may be DAC, SELinux or another restriction.\n"
              "Use a matching AVC denial to identify SELinux; missing logs are inconclusive.\n"
              "An empty/denied SPI listing does not establish absence of SPI hardware.\n"
              "Open success proves only that this app could open at this instant, not transfers.\n");
    if (r->used == sizeof(r->text) - 1) {
        const char marker[] = "\n[REPORT TRUNCATED]\n";
        memcpy(r->text + r->used - (sizeof(marker) - 1), marker, sizeof(marker) - 1);
    }
}

#ifndef PROBE_TEST
JNIEXPORT jbyteArray JNICALL
Java_dev_t865_portprobe_MainActivity_inspect(JNIEnv *env, jobject activity, jboolean probe) {
    (void)activity;
    Report *r = calloc(1, sizeof(*r));
    if (r == NULL) {
        jclass type = (*env)->FindClass(env, "java/lang/OutOfMemoryError");
        if (type != NULL) (*env)->ThrowNew(env, type, "Cannot allocate inspection report");
        return NULL;
    }
    collect_report(r, probe == JNI_TRUE);
    jbyteArray bytes = (*env)->NewByteArray(env, (jsize)r->used);
    if (bytes != NULL) (*env)->SetByteArrayRegion(env, bytes, 0, (jsize)r->used, (const jbyte *)r->text);
    free(r);
    return bytes;
}
#endif
