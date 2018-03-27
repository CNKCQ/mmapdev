//
//  ViewController.m
//  mmapdev
//
//  Created by steve on 18/03/2018.
//  Copyright © 2018 steve. All rights reserved.
//

#import "ViewController.h"
#include <sys/types.h>
#include <sys/mman.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "LogWriter.h"


@interface ViewController ()

@end

NS_INLINE bool writer() {
    LogWriter *logWriter = new LogWriter();
    
    NSString *tmpDir = NSTemporaryDirectory();
    const char *dir1 = [[NSString stringWithFormat:@"%@", tmpDir] cStringUsingEncoding:NSUTF8StringEncoding];
    logWriter->init("llkl\n", dir1, "key");
    for (int i = 0; i < 10; i ++) {
        logWriter->writeLog("mmap word \n", false);
    }
    logWriter->closeWriter();
    return true;
}

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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    writer();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
}


@end

