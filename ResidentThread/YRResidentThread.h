//
//  YRResidentThread.h
//  ResidentThread
//
//  Created by yangrui on 2018/7/18.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YRResidentThreadTask)(void);

// 常驻线程
@interface YRResidentThread : NSThread


/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(YRResidentThreadTask)task;

/**
 结束线程
 */
- (void)stop;

@end
