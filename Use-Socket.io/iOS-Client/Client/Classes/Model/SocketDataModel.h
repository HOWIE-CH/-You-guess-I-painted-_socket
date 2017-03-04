
/*!
 @header SocketDataModel.h
 @abstract socket传递模型
 @author zhanghao on 17/2/8
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class DIYBezierPath;

@interface SocketDataModel : NSObject
/*!
 @property 贝塞尔曲线
 @abstract 贝塞尔曲线
 */
@property (nonatomic, strong) DIYBezierPath *path;
/*!
 @property 聊天的文字
 @abstract 聊天的文字
 */
@property (nonatomic, copy) NSString *chatString;

@end
