//
//  ViewController.m
//  ResidentThread
//
//  Created by yangrui on 2018/7/18.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import "YRResidentThread.h"

@interface ViewController ()

@property(nonatomic, strong)YRResidentThread *residentThread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建常驻线程,线程自动运行
    self.residentThread = [[YRResidentThread alloc] init];
   
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // 在常驻线程中执行任务
    [self.residentThread executeTask:^{
        NSLog(@"---------%@@", [NSThread currentThread]);
    }];
}

- (IBAction)stopBtnClick:(id)sender {
    // 主动销毁线程
    [self.residentThread stop];
    
    // 或者调用小面的方法
    //self.residentThread = nil;
}



@end
