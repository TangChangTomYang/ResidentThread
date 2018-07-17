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

/** 用于控制常驻线程内的runloop 是否要继续运行*/
@property(nonatomic, assign,getter=isStop)BOOL stop;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}


-(void)setupResidentThread{
    self.stop = NO;
    typeof(self) weakSelf = self;
    // 创建常驻线程
    self.residentThread = [[YRResidentThread alloc] initWithBlock:^{
        
        NSLog(@"residentThread begin-----------");
        
        //1. 创建子线程runloop,并添加 Source / Timer / Observer 只要runloop 的mode中有 Source / Timer / Observer 其中的一个就不会死(NSPort 也是一种Source)
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc]init]  forMode: NSDefaultRunLoopMode];
        
        //3. 控制runloop 是否继续跑(运行)
        while (weakSelf != nil && weakSelf.isStop == NO ) {
            //2.让子线程的runloop 跑起来( 这个方法,runloop 只跑一圈,runloop 是否继续跑,依赖于外面的while循环来控制)
            // 如果runloop 在运行 ,此句代码后面的语句将永远不会被执行,这时runloop的特点
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            // 注意不要使用下面这个方法让你的runloop 跑起来,下面这个跑起来就听不了了
            //[NSRunLoop currentRunLoop];
        }
        // 常驻线程挂掉才会来这里
         NSLog(@"residentThread end-----------");
    }];
    // 启动常驻线程
    [self.residentThread start];
}

-(void)stopResidentAndRunLoop{
    // 注意 waitUntilDone:YES 必须要写yes(必须要保证runloop和常驻线程死了才能销毁控制器),否则会包 坏内存访问
     [self performSelector:@selector(stopRunLoop) onThread:self.residentThread withObject:nil waitUntilDone:YES];
}

-(void)stopRunLoop{
    
    // 标记常驻线程是否继续运行
    self.stop = YES;
    
    // 停止runloop
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"%s, %@",__func__, [NSThread currentThread]);
    
}




-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(test) onThread:self.residentThread withObject:nil waitUntilDone:NO];
}

-(void)test{
    NSLog(@"%s",__func__);
}


- (IBAction)stopBtnClick:(id)sender {
    [self stopResidentAndRunLoop];
}

-(void)dealloc{
    NSLog(@"%s",__func__);
    
    if (self.isStop == NO) {
        // 在控制器销毁前 停掉 常驻线程
          [self stopResidentAndRunLoop];
        //技巧,如果想在dealloc 销毁前做完某件事,可以调用下面的方法
//        [self performSelector:@selector(dealloc 销毁前需要完成的方法) onThread:指定的线程 withObject:nil waitUntilDone:YES];
        
    }
    
}

@end
