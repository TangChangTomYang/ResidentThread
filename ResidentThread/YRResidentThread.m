//
//  YRResidentThread.m
//  ResidentThread
//
//  Created by yangrui on 2018/7/18.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRResidentThread.h"
/** YRThread **/
@interface YRThread : NSThread
@end
@implementation YRThread
- (void)dealloc{
    NSLog(@"%s", __func__);
}
@end


/** YRResidentThread **/
@interface YRResidentThread()
@property (strong, nonatomic) YRThread *innerThread;
@property(nonatomic, assign, getter=isStoped)BOOL stoped;
@end
@implementation YRResidentThread

#pragma mark - public methods
/** 创建常驻线程后 常驻线程自动运行*/
- (instancetype)init{
    
    if (self = [super init]) {
        
        self.stoped = NO;
        __weak typeof(self) weakSelf = self;
        self.innerThread = [[YRThread alloc] initWithBlock:^{
            NSLog(@" runloop begin----");
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            
            while (weakSelf != nil && weakSelf.isStoped == NO) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            NSLog(@" runloop end----");
            
        }];
        
        [self.innerThread start];
    }
    return self;
}


- (void)executeTask:(YRResidentThreadTask)task{
   
    if (!self.innerThread || !task) return;
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

- (void)stop{
    
    if (!self.innerThread) return;
    self.stoped = YES;
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

- (void)dealloc{
    NSLog(@"%s", __func__);
    [self stop];
}

#pragma mark - private methods
- (void)__stop{
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(YRResidentThreadTask)task{
    task();
}


@end
