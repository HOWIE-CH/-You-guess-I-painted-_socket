//
//  main.m
//  server
//
//  Created by zhanghao on 17/2/8.
//  Copyright © 2017年 com.bluestar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Server *chatServer = [[Server alloc]init];
        [chatServer startServer];
        // 开启主运行循环
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
