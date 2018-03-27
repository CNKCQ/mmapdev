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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_t queue = dispatch_queue_create("mmapqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        writer();
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
}


@end

