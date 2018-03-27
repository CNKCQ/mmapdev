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

static void
check (int condition, const char * message, ...)
{
    if (condition) {
        va_list args;
        va_start (args, message);
        vfprintf (stderr, message, args);
        va_end (args);
        fprintf (stderr, "\n");
    }
}


NS_INLINE bool writer() {
    LogWriter *logWriter = new LogWriter();
    
    NSString *tmpDir = NSTemporaryDirectory();
    const char *dir1 = [[NSString stringWithFormat:@"%@", tmpDir] cStringUsingEncoding:NSUTF8StringEncoding];
    logWriter->init("llkl\n", dir1, "key");
    for (int i = 0; i < 10; i ++) {
        logWriter->writeLog("mmap word \n", false);
    }
    logWriter->closeWriter();
    free(logWriter);
    return true;
}

NS_INLINE void *reader() {
    NSString *tmpDir = NSTemporaryDirectory();
    const char *dir1 = [[NSString stringWithFormat:@"%@2018-03-27-mmap", tmpDir] cStringUsingEncoding:NSUTF8StringEncoding];
    void *mapped;
    int _offset = 0;
    int fd;
    int page_size;
    fd = open(dir1,
              (O_RDWR),
              (S_IRWXU | S_IRWXG | S_IRWXO) );
    check (fd < 0, "open %s failed: %s", dir1, strerror (errno));
    page_size = (int)sysconf(_SC_PAGESIZE);
    lseek(fd, page_size - 1, SEEK_SET);
    int len;
    len = page_size;   /* Map one page */
    mapped = mmap(NULL,
                   len,
                   PROT_READ,
                   MAP_SHARED,
                   fd,
                   _offset);
    check (mapped == MAP_FAILED, "mmap %s failed: %s",
           dir1, strerror (errno));
    const char *result = (const char *)mapped;
    printf("\n 👌--🌹 === %s", result);
    close(fd);
    unlink(dir1);
    return mapped;
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_t queue = dispatch_queue_create("mmapqueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//        writer();
//    });
    dispatch_async(queue, ^{
        reader();
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
}


@end

