
/*!
 @header DIYBezierPath.h
 @abstract 贝塞尔曲线模型（增加曲线颜色属性）
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface DIYBezierPath : UIBezierPath
/*!
 @property 曲线颜色
 @abstract 曲线颜色
 */
@property (nonatomic, strong) UIColor *pathColor;

@end
