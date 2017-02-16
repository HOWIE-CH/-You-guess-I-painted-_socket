
/*!
 @header DIYDrawView.h
 @abstract 画板
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */


#import <UIKit/UIKit.h>

@class DIYBezierPath;

@interface DIYDrawView : UIView

/*!
 @property 当前的贝塞尔曲线路径
 @abstract 当前的贝塞尔曲线路径
 */
@property (nonatomic, strong) DIYBezierPath *currentPath;
/*!
 @property 贝塞尔曲线路径数组
 @abstract 贝塞尔曲线路径数组
 */
@property (nonatomic, strong) NSMutableArray *pathArray;
/*!
 @property 线宽
 @abstract 线宽
 */
@property (nonatomic, assign) CGFloat width;
/*!
 @property 线颜色
 @abstract 线颜色
 */
@property (nonatomic, strong) UIColor *color;
/*!
 @property 背景图
 @abstract 背景图
 */
@property (nonatomic, strong) UIImage *drawImg;

/*!
 @property 回调
 @abstract 画完一笔之后的回调
 */
@property (nonatomic, copy) void (^pathBlock)(DIYBezierPath *path);

/*!
 @method  清空画板
 @abstract 清空画板
 */
- (void)clear;
/*!
 @method  撤销最后一笔的画
 @abstract 撤销最后一笔的画
 */
- (void)undo;
/*!
 @method  橡皮擦功能
 @abstract 橡皮擦功能
 */
- (void)erasure;



@end
