
/*!
 @header DIYDrawView.m
 @abstract 画板
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import "DIYDrawView.h"
#import "DIYBezierPath.h"

@interface DIYDrawView ()

/*!
 @property 路径颜色
 @abstract 路径颜色
 */
@property (nonatomic, strong) UIColor *pathColor;
/*!
 @property 路径宽度
 @abstract 路径宽度
 */
@property (nonatomic, assign) CGFloat pathWidth;


@end

@implementation DIYDrawView

#pragma mark - 懒加载
/*!
 @method  懒加载
 @abstract 初始化路径数组
 @result 路径数组
 */
- (NSMutableArray *)pathArray {
    if (_pathArray == nil) {
        _pathArray = [NSMutableArray array];
    }
    return _pathArray;
}
#pragma mark - 初始化
/*!
 @method  系统方法
 @abstract 从代码初始化
 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
/*!
 @method  系统方法
 @abstract 从xib初始化
 */
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
/*!
 @method  初始化配置
 @abstract 初始化配置
 */
- (void)setup {
    // ----- 定义初始默认的 颜色及线宽 -----
    self.pathColor = [UIColor blackColor];
    self.pathWidth = 5.5;
    self.width = self.pathWidth;
    self.color = self.pathColor;
    
}

#pragma mark - touch 事件

/*!
 @method  系统方法，开始点击view
 @abstract 监听开始点击view事件（开始画画）
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint startPoint = [self getCurrentPointWithTouches:touches];
    DIYBezierPath *path = [DIYBezierPath bezierPath];
    [path moveToPoint: startPoint];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = self.pathWidth;
    path.pathColor = self.pathColor;
    self.currentPath = path;
    [self.pathArray addObject:path];
    
    
}
/*!
 @method  系统方法，手指在view上移动
 @abstract 监听手指在view上移动事件（生成路径）
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint currentPoint = [self getCurrentPointWithTouches:touches];
    
    
    [self.currentPath addLineToPoint:currentPoint];
    [self setNeedsDisplay];
}
/*!
 @method  系统方法，手指在view上点击结束，离开view
 @abstract 手指在view上点击结束事件（开始socket传递数据，回调）
 */
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // socket 传数据
    self.pathBlock(self.pathArray.lastObject);
}
/*!
 @method  获取手指位置的坐标点
 @abstract 获取手指位置的坐标点
 @param touches touches
 @result 坐标点
 */
- (CGPoint)getCurrentPointWithTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    return [touch locationInView:touch.view];
}

#pragma mark - 画画相关操作
/*!
 @method  清空画板
 @abstract 清空画板
 */
- (void)clear {
    [self.pathArray removeAllObjects];
    [self setNeedsDisplay];
}
/*!
 @method  撤销最后一笔的画
 @abstract 撤销最后一笔的画
 */
- (void)undo {
    [self.pathArray removeLastObject];
    [self setNeedsDisplay];
    
}
/*!
 @method  橡皮擦功能
 @abstract 橡皮擦功能
 */
- (void)erasure {
    // 当背景没有图片的时候 是这样的
    self.pathColor = self.backgroundColor;
//    [self setNeedsDisplay];
    
}
#pragma mark - setter方法，监听

/*!
 @method  setter方法
 @abstract 监听颜色的选择改变
 */
- (void)setColor:(UIColor *)color {
    _color = color;
    self.pathColor = color;
}
/*!
 @method  setter方法
 @abstract 监听线宽度的选择改变
 */
- (void)setWidth:(CGFloat)width {
    _width = width;
    self.pathWidth = width;
}
/*!
 @method  setter方法
 @abstract 监听背景图的的选择改变
 */
- (void)setDrawImg:(UIImage *)drawImg {
    if (drawImg) {
        _drawImg = drawImg;
        [self.pathArray addObject:drawImg];
        [self setNeedsDisplay];
    } else {
        NSLog(@"图片nil");
    }
}
#pragma mark - drawRect

/*!
 @method  系统方法
 @abstract drawRect
 */
- (void)drawRect:(CGRect)rect {
    if (self.pathArray.count) {
        for (DIYBezierPath *path in self.pathArray) {
            if ([path isKindOfClass:[DIYBezierPath class]]) {
                [path.pathColor set];
                [path stroke];
                
            } else if ([path isKindOfClass:[UIImage class]]) {
                UIImage *img = (UIImage *)path;
                
                [img drawInRect:rect];
            }
            
            
        }
    }
}


@end
