
/*!
 @header DIYChoseImgView.h
 @abstract 选择图片，编辑图片
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import <UIKit/UIKit.h>

typedef void(^myBlock)(UIImage *);

@interface DIYChoseImgView : UIView
/*!
 @property 处理完图片后的回调
 @abstract 处理完图片后的回调
 */
@property (nonatomic, copy) myBlock block;
/*!
 @property 需要处理的图片
 @abstract 需要处理的图片
 */
@property (nonatomic, strong) UIImage *img;
@end
