
/*!
 @header UIImage+DIY.m
 @abstract 图片处理分类
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import "UIImage+DIY.h"

@implementation UIImage (DIY)

/*!
 @method  指定view 进行截屏
 @abstract 通过指定view的frame 进行截屏
 @param view 指定view
 @result 裁剪后的图片
 */
+ (instancetype)imgClipScreenWithView:(UIView *)view {
    CGRect rect = view.frame;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [view.layer renderInContext:ctx];
    UIImage *clipImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipImg;
}
@end
