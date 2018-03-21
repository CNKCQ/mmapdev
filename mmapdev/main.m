//
//  main.m
//  mmapdev
//
//  Created by steve on 18/03/2018.
//  Copyright © 2018 steve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <sys/types.h>
#include <sys/mman.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        size_t bytesWritten = 0;
        int  offset = 0;
        char  *text1 = "Data for file 1.";
        char  *text2 = "Data for file 2.";
        int fd1,fd2;
        int pageSize;
        void *address;
        void *address2;

        NSString *tmpDir = NSTemporaryDirectory();
        NSLog(@"🌹---%@", tmpDir);
        const char *dir1 = [[NSString stringWithFormat:@"%@mmaptest1", tmpDir] cStringUsingEncoding:NSUTF8StringEncoding];
        fd1 = open(dir1,
                   (O_CREAT | O_TRUNC | O_RDWR),
                   (S_IRWXU | S_IRWXG | S_IRWXO) );

        bytesWritten = write(fd1, text1, strlen(text1));
        if ( bytesWritten != strlen(text1) ) {
            perror("write() error");
            //            int closeRC = close(fd1);
            return -1;
        }
        const char *dir2 = [[NSString stringWithFormat:@"%@mmaptest2", tmpDir] cStringUsingEncoding:NSUTF8StringEncoding];
        fd2 = open(dir2,
                   (O_CREAT | O_TRUNC | O_RDWR),
                   (S_IRWXU | S_IRWXG | S_IRWXO) );

        bytesWritten = write(fd2, text2, strlen(text2));
        if ( bytesWritten != strlen(text2) )
            perror("write() error");

        pageSize = (int)sysconf(_SC_PAGESIZE);
        {

            //                off_t lastoffset = lseek( fd1, PageSize-1, SEEK_SET);
            {
                bytesWritten = write(fd1, " ", 1);   /* grow file 1 to 1 page. */

                //                    off_t lastoffset = lseek( fd2, PageSize-1, SEEK_SET);

                bytesWritten = write(fd2, " ", 1);   /* grow file 2 to 1 page. */
                /*
                 *  We want to show how to memory map two files with
                 *  the same memory map.  We are going to create a two page
                 *  memory map over file number 1, even though there is only
                 *  one page available. Then we will come back and remap
                 *  the 2nd page of the address range returned from step 1
                 *  over the first 4096 bytes of file 2.
                 */

                int len;

                offset = 0;
                len = pageSize;   /* Map one page */
//                void *mmap(void *addr, size_t length, int prot, int flags,
//                           int fd, off_t offset);
                address = mmap(NULL,
                               len,
                               PROT_READ,
                               MAP_SHARED,
                               fd1,
                               offset );
                if ( address != MAP_FAILED ) {
                    address2 = mmap( ((char*)address)+pageSize,
                                    len,
                                    PROT_READ,
                                    MAP_SHARED | MAP_FIXED, fd2,
                                    offset );
                    if ( address2 != MAP_FAILED ) {
                        /* print data from file 1 */
                        printf("\n%s",dir1);
                        printf("\n%s",dir2);
                        printf("\n%s",address);
                        /* print data from file 2 */
                        printf("\n%s",address2);
                    } /* address 2 was okay. */
                    else {
                        perror("mmap() error=");
                    } /* mmap for file 2 failed. */
                }
                else {
                    perror("munmap() error=");
                }
                /*
                 *  Unmap two pages.
                 */
                if ( munmap(address, 2*pageSize) < 0) {
                    perror("munmap() error");
                }
                else;

            }
        }
        close(fd2);
        unlink( dir1);

        close(fd1);
        unlink( dir2);
        /*
         *  Unmap two pages.
         */
        if ( munmap(address, 2*pageSize) < 0) {
            perror("munmap() error");
        }
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

// see: https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man2/mmap.2.html
// http://man7.org/linux/man-pages/man2/mmap.2.html
// https://searchcode.com/codesearch/view/45933225/
// https://searchcode.com/codesearch/view/45933225/
// https://lemire.me/blog/2012/06/26/which-is-fastest-read-fread-ifstream-or-mmap/

