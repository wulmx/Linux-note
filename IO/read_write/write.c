#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define __USE_GNU 1
#include <fcntl.h>
#include <errno.h>

/*
 * O_DIRECT flag must comply with 2 rules:
 * 	1) posix_memalign aligns memory for buf's head-address
 * 	2) smallest unit is sector-size, normal is 512 (1<<9)
 *
 * pwrite/pread will not change the offset, can omit the lseek operation
 *
 */

#define ALIGN_SIZE 1ull << 12
#define WR_SIZE 1ull << 12
//static const int OPEN_FLAGS = O_RDWR | O_CREAT | O_SYNC;
static const int OPEN_FLAGS = O_RDWR | O_CREAT | O_DIRECT;
//static const int OPEN_FLAGS = O_RDWR | O_CREAT;
static const mode_t OPEN_MODE = S_IRUSR | S_IWUSR;

int main()
{
    int fd;
    int res;
    //char buf[] = "wlm";
    char *buf;
    
    sleep(5); // trace it
    //fd = open("/dev/vda3", OPEN_FLAGS, OPEN_MODE);
    fd = open("testdata", OPEN_FLAGS, OPEN_MODE);
    if (fd < 0) {
        fprintf(stderr, "prepare/open: %s\n", strerror(errno));
   	return -1;
    }
    /* aligns block page size for memory */
    if (posix_memalign((void**)&buf, ALIGN_SIZE, WR_SIZE)) {
        perror("posix_memalign");
    }

    res = write(fd, buf, 1ull << 10);
    //res = pwrite(fd, buf, sizeof(buf), 1ull << 10);
    if (res < 0) {
        fprintf(stderr, "prepare/pwrite1: %s\n", strerror(errno));
        return -1;
    }
    res = write(fd, buf, 1ull << 9);
    if (res < 0) {
        fprintf(stderr, "prepare/pwrite2: %s\n", strerror(errno));
        return -1;
    }
    //fsync(fd);
    res = read(fd, buf, 1ull << 10);
    if (res < 0) {
        perror("read error");
    }
    res = read(fd, buf, 1ull << 9);
    if (res < 0) {
        perror("read error");
    }
    close(fd);
}
