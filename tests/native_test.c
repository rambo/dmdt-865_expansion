/* Includes production code with fake open/read/close/lstat; touches no devices. */
#define _GNU_SOURCE
#include <assert.h>
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

static int opens, closes, reads, flags, open_error, close_error;
static mode_t fake_type = S_IFCHR;
static int fake_open(const char *path, int requested, ...) {
    opens++;
    flags = requested;
    if (strncmp(path, "/dev/", 5) != 0) return 43;
    if (open_error) { errno = open_error; return -1; }
    return 42;
}
static ssize_t fake_read(int fd, void *buf, size_t size) {
    reads++;
    assert(fd != 42); /* Device descriptors must never be read. */
    assert(fd == 43 && size >= 2);
    memcpy(buf, "1\n", 2);
    return 2;
}
static int fake_close(int fd) {
    assert(fd == 42 || fd == 43);
    if (fd == 43) return 0;
    closes++;
    if (close_error) { errno = close_error; return -1; }
    return 0;
}
static int fake_lstat(const char *path, struct stat *st) {
    (void)path;
    memset(st, 0, sizeof(*st));
    st->st_mode = fake_type | 0600;
    return 0;
}
#define open fake_open
#define read fake_read
#define close fake_close
#define lstat fake_lstat
#define PROBE_TEST
#include "../app/src/main/cpp/probe.c"

int main(void) {
    Report r = {0};
    assert(allowed_device("/dev/ttysWK0"));
    assert(allowed_device("/dev/ttysWK3"));
    assert(allowed_device("/dev/spidev12.34"));
    const char *bad[] = {"/dev/ttysWK4", "/dev/ttysWK00", "/dev/ttyS0",
        "/dev/spidev", "/dev/spidev.0", "/dev/spidev0.", "/dev/spidev0.0x",
        "/dev/spidev0.0/../ttyS0", "/tmp/spidev0.0"};
    for (size_t i = 0; i < sizeof(bad) / sizeof(bad[0]); i++) {
        assert(!allowed_device(bad[i]));
        device(&r, bad[i], true);
    }
    assert(opens == 0);
    device(&r, "/dev/ttysWK0", false);
    assert(opens == 0 && strstr(r.text, "NOT REQUESTED"));
    device(&r, "/dev/ttysWK0", true);
    assert(opens == 1 && closes == 1 && reads == 0);
    assert((flags & O_ACCMODE) == O_RDONLY);
    assert(flags == (O_RDONLY | O_NONBLOCK | O_NOCTTY | O_CLOEXEC | O_NOFOLLOW));
    assert(strstr(r.text, "errno=0"));
    open_error = EACCES;
    device(&r, "/dev/ttysWK1", true);
    assert(opens == 2 && closes == 1 && strstr(r.text, "EACCES"));
    open_error = ENOENT;
    device(&r, "/dev/ttysWK2", true);
    assert(opens == 3 && closes == 1 && strstr(r.text, "ENOENT"));
    open_error = 0;
    close_error = EINTR;
    device(&r, "/dev/spidev0.0", true);
    assert(opens == 4 && closes == 2 && strstr(r.text, "device close: -1"));
    fake_type = S_IFLNK;
    device(&r, "/dev/spidev0.0", true);
    fake_type = S_IFREG;
    device(&r, "/dev/ttysWK0", true);
    assert(opens == 4 && reads == 0);
    r.used = 0;
    r.text[0] = '\0';
    collect_report(&r, false);
    assert(opens > 4 && closes == 2 && reads > 0);
    assert(strstr(r.text, "value: 1\n"));
    assert(strstr(r.text, "METADATA ONLY"));
    assert(strstr(r.text, "/sys/class/spi_master"));
    assert(strstr(r.text, "/sys/bus/spi/devices"));
    assert(strstr(r.text, "/sys/class/spidev"));
    for (int i = 0; i < REPORT_CAPACITY; i++) append(&r, "padding");
    assert(r.used == REPORT_CAPACITY - 1 && r.text[r.used] == '\0');
    puts("PASS: allowlist, metadata-only, read-only flags, errno, close-once, symlink/non-character rejection, no device reads, bounded report");
}
