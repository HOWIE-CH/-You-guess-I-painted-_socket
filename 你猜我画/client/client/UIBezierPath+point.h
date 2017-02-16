
/*!
 @header UIBezierPath+point.h
 @abstract 通过贝塞尔图片获取点坐标
 @author zhanghao on 17/2/8
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface UIBezierPath (point)
/*!
 @method  获得UIBezierPath曲线上的所有点坐标
 @abstract 获得UIBezierPath曲线上的所有点坐标
 @result 坐标点数组
 */
- (NSArray *)points;

@end
