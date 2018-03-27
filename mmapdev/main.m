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
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

// see: https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man2/mmap.2.html
// http://man7.org/linux/man-pages/man2/mmap.2.html
// https://searchcode.com/codesearch/view/45933225/
// https://searchcode.com/codesearch/view/45933225/
// https://lemire.me/blog/2012/06/26/which-is-fastest-read-fread-ifstream-or-mmap/
// example useage: https://github.com/path/FastImageCache
// https://www.ibm.com/support/knowledgecenter/en/ssw_i5_54/apis/mmap.htm
// https://lwn.net/Articles/357767/
// https://sqlite.org/mmap.html
// https://www.ibm.com/developerworks/cn/linux/l-ipc/part5/index1.html
// https://github.com/realm/realm-core/blob/a61e586bf9fccdfb648aa345a786e6cff52010a4/src/realm/util/file_mapper.cpp
// https://www.sqlite.org/mmap.html
// https://www.lemoda.net/c/mmap-example/index.html
// https://gist.github.com/marcetcheverry/991042


NS_INLINE int do_mmap() {
    size_t bytesWritten = 0;
    int   _offset = 0;
    char *text1 = "Data for file 1";
    char *text2 = "Data for file 2";
    int fd1,fd2;
    int page_size;
    void *address;
    void *address2;
    
    NSString *tmpDir = NSTemporaryDirectory();
    const char *dir1 = [[NSString stringWithFormat:@"%@mmaptest1", tmpDir] cStringUsingEncoding:NSUTF8StringEncoding];
    
    fd1 = open(dir1,
               (O_CREAT | O_TRUNC | O_RDWR),
               (S_IRWXU | S_IRWXG | S_IRWXO) );
    bytesWritten = write(fd1, text1, strlen(text1));
    if ( bytesWritten != strlen(text1) ) {
        perror("write() error");
        close(fd1);
        return -1;
    }
    
    fd2 = open(dir1,
               (O_CREAT | O_TRUNC | O_RDWR),
               (S_IRWXU | S_IRWXG | S_IRWXO) );
    
    
    bytesWritten = write(fd2, text2, strlen(text2));
    if ( bytesWritten != strlen(text2) )
        perror("write() error");
    
    page_size = (int)sysconf(_SC_PAGESIZE);
    
    lseek( fd1, page_size - 1, SEEK_SET);
    bytesWritten = write(fd1, " ", 1);   /* grow file 1 to 1 page. */
    
    lseek( fd2, page_size - 1, SEEK_SET);
    
    bytesWritten = write(fd2, " ", 2);   /* grow file 2 to 1 page. */
    int len;
    
    _offset = 0;
    len = page_size;   /* Map one page */
    address = mmap(NULL,
                   len,
                   PROT_READ,
                   MAP_SHARED,
                   fd1,
                   _offset);
    if ( address != MAP_FAILED ) {
        address2 = mmap( ((char*)address) + page_size,
                        len,
                        PROT_READ,
                        MAP_SHARED | MAP_FIXED, fd2,
                        _offset );
        if ( address2 != MAP_FAILED ) {
            /* print data from file 1 */
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
    if ( munmap(address, 2 * page_size) < 0) {
        perror("munmap() error");
    }
    else;
    close(fd2);
    unlink( "/tmp/mmaptest2");
    close(fd1);
    unlink( "/tmp/mmaptest1");
    /*
     *  Unmap two pages.
     */
    if ( munmap(address, 2 * page_size) <    0) {
        perror("munmap() error");
    }
    else;
    return -1;
}
