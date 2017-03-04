
/*!
 @header DIYChoseImgView.m
 @abstract 选择图片，编辑图片
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import "DIYChoseImgView.h"
#import "UIImage+DIY.h"

@interface DIYChoseImgView () <UIGestureRecognizerDelegate>
/*!
 @property 图片View
 @abstract 图片View
 */
@property (nonatomic, weak) UIImageView *imgView;

@end

@implementation DIYChoseImgView


/*!
 @method  setter
 @abstract 监听需要处理的图片的赋值
 */
- (void)setImg:(UIImage *)img {
    _img = img;
    self.imgView.image = img;
}
/*!
 @method  系统方法
 @abstract 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.frame = self.bounds;
        imgView.userInteractionEnabled = YES;
        [self addSubview:imgView];
        self.imgView = imgView;
        
        self.backgroundColor = [UIColor clearColor];
        // ----- 手势 -----
        [self setupGes];
    }
    return self;
}
/*!
 @method  初始化手势
 @abstract 初始化手势
 */
- (void)setupGes {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGes:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGes:)];
    pan.delegate = self;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGes:)];
    pinch.delegate = self;
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationGes:)];
    rotation.delegate = self;
    
    [self.imgView addGestureRecognizer:tap];
    [self.imgView addGestureRecognizer:pan];
    [self.imgView addGestureRecognizer:pinch];
    [self.imgView addGestureRecognizer:rotation];
}
/*!
 @method  监听点击手势事件
 @abstract 监听点击手势事件
 */
- (void)tapGes:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.3 animations:^{
        self.imgView.alpha = 0;
    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.imgView.alpha = 1;
        } completion:^(BOOL finished) {
            // ----- 截图 -----
            UIImage *newImg = [UIImage imgClipScreenWithView:self];
            self.block(newImg);
            // ----- 移除clearView -----
            [self removeFromSuperview];
            
        }];
    }];
}
/*!
 @method  监听pan手势事件
 @abstract 监听pan手势事件
 */
- (void)panGes:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan translationInView:pan.view];
    self.imgView.transform = CGAffineTransformTranslate(self.imgView.transform, currentPoint.x, currentPoint.y);
    [pan setTranslation:CGPointZero
                 inView:pan.view];
}
/*!
 @method  监听pinch手势事件
 @abstract 监听pinch手势事件
 */
- (void)pinchGes:(UIPinchGestureRecognizer *)pinch {
    self.imgView.transform = CGAffineTransformScale(self.imgView.transform, pinch.scale, pinch.scale);
    [pinch setScale:1.0];
}
/*!
 @method  监听rotation手势事件
 @abstract 监听rotation手势事件
 */
- (void)rotationGes:(UIRotationGestureRecognizer *)rotation {
    self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, rotation.rotation);
    [rotation setRotation:0.0];
}

#pragma mark - <UIGestureRecognizerDelegate>
/*!
 @method  系统方法
 @abstract 多手势支持
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
