
/*!
 @header ViewController.m
 @abstract 模拟你猜我画简单demo， 涉及socket传图片、文字、坐标点
 @author zhanghao on 16/10/13
 @version 1.00 Copyright © 2016年 蓝星软件. All rights reserved.
 */

#import "ViewController.h"
#import "DIYDrawView.h"
#import "DIYChoseImgView.h"
#import "UIImage+DIY.h"
#import "SocketDataModel.h"
#import "UIBezierPath+point.h"
#import "DIYBezierPath.h"
#import "MBProgressHUD+NJ.h"

#import "Client-swift.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate>
/*!
 @property 画图区域view
 @abstract 画图区域view
 */
@property (weak, nonatomic) IBOutlet DIYDrawView *drawView;
/*!
 @property 聊天输入框
 @abstract 聊天输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
/*!
 @property 画图区域view的高度约束
 @abstract 画图区域view的高度约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawViewHeight_LC;

/*!
 @property 接受到socket数据
 @abstract 接受到socket数据（针对图片数据流的拼接）
 */
@property (nonatomic, copy) NSMutableString *socketReadData;

/*!
 @property socket传递数据模型
 @abstract socket传递数据模型
 */
@property (nonatomic, strong) SocketDataModel *dataModel;
/*!
 @property 客户端socket
 @abstract 客户端socket
 */
@property (nonatomic, strong) SocketIOClient *clientSocket;
/*!
 @property 聊天文字数组
 @abstract 聊天文字数组
 */
@property (nonatomic, strong) NSMutableArray *chatArray;
/*!
 @property tableView
 @abstract tableView
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ViewController

#pragma mark - 懒加载
/*!
 @method 懒加载 
 @abstract 初始化socket传输的二进制数据
 @result 初始化的二进制数据
 */
- (NSMutableString *)socketReadData {
    if (!_socketReadData) {
        _socketReadData = [NSMutableString string];
    }
    return _socketReadData;
}
/*!
 @method 懒加载
 @abstract 初始化客户端socket对象
 @result 客户端socket对象
 */
- (SocketIOClient *)clientSocket {
    if (!_clientSocket) {
       
        NSURL *url = [NSURL URLWithString:@"http://webapp.howiech.com"];
       
        _clientSocket = [[SocketIOClient alloc]initWithSocketURL:url
                                                          config:@{@"log": @YES, @"forcePolling": @YES}];
        
    }
    return _clientSocket;
}
/*!
 @method 懒加载
 @abstract 初始化聊天数据数组
 @result 聊天数据数组
 */
- (NSMutableArray *)chatArray {
    if (!_chatArray) {
        _chatArray = [NSMutableArray array];
    }
    return _chatArray;
}
#pragma mark - 控制器生命周期
/*!
 @method  系统方法
 @abstract 控制器生命周期
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.让图片区域宽度等于屏幕宽度，图片高度等于屏幕宽度，设置图片等宽等高
    self.drawViewHeight_LC.constant =  [UIScreen mainScreen].bounds.size.width;
    [self.view layoutIfNeeded];
   
    [MBProgressHUD showMessage:@"正在连接服务器，哎，很慢的!"
                        toView:self.view];
    // 2.连接服务器
    [self.clientSocket connect];
    
    
    
    [self.clientSocket on:@"connection" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showSuccess:@"亲，服务器连接成功！"];
    }];
    
    __weak typeof(self) weakSelf = self ;
    [self.drawView setPathBlock:^(DIYBezierPath *path) {
        
        weakSelf.dataModel = [[SocketDataModel alloc]init];
        weakSelf.dataModel.path = path;
        // 实时传递数据
        [weakSelf sendPath];
    }];
    
    
    
    // 键盘
    self.chatTextField.delegate = self;
    
    [self receiveImg];
    [self receivePath];
    [self receiveText];
    
    
}

#pragma mark - 内部事件（按钮点击）

/*!
 @method  UISlider值改变事件
 @abstract 监听UISlider值的改变事件
 @param sender UISlider
 */
- (IBAction)widthValueChange:(UISlider *)sender {
    self.drawView.width = sender.value;
}
/*!
 @method  颜色按钮的点击
 @abstract 监听颜色按钮的点击事件
 @param sender 颜色按钮
 */
- (IBAction)colorBtnClick:(UIButton *)sender {
    self.drawView.color = sender.backgroundColor;
}
/*!
 @method  清除按钮的点击
 @abstract 监听清除按钮的点击事件
 @param sender 清除按钮
 */
- (IBAction)clear:(id)sender {
    [self.drawView clear];
}
/*!
 @method  撤销按钮的点击
 @abstract 监听撤销按钮的点击事件
 @param sender 撤销按钮
 */
- (IBAction)undo:(id)sender {
    [self.drawView undo];
}
/*!
 @method  橡皮擦按钮的点击
 @abstract 监听橡皮擦按钮的点击事件
 @param sender 橡皮擦按钮
 */
- (IBAction)erasure:(id)sender {
    [self.drawView erasure];
}
/*!
 @method  选择图片按钮的点击
 @abstract 监听选择图片按钮的点击事件
 @param sender 选择图片按钮
 */
- (IBAction)photo:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        UIImagePickerController *imgPickerVC = [[UIImagePickerController alloc]init];
        
        imgPickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imgPickerVC.delegate = self;
        
        [self presentViewController:imgPickerVC
                           animated:YES
                         completion:nil];
    }
    
    
    
    
}
/*!
 @method  保存图片按钮的点击
 @abstract 监听保存图片按钮的点击事件
 @param sender 保存图片按钮
 */
- (IBAction)save:(id)sender {
    
    UIImage *saveImg = [UIImage imgClipScreenWithView:self.drawView];
    UIImageWriteToSavedPhotosAlbum(saveImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}
/*!
 @method  发送路径
 @abstract 通过socket 发送路径信息
 */
- (void)sendPath {
    // path 坐标点及 转换
    NSArray *points = [(UIBezierPath *)self.dataModel.path points];
    NSMutableArray *tmp = [NSMutableArray array];
    for (id value in points) {
        CGPoint point = [value CGPointValue];
        NSDictionary *dic = @{@"x" : @(point.x), @"y": @(point.y)};
        [tmp addObject:dic];
    }
    
    // 颜色类别
    NSInteger colorNum = 0;
    
    if (CGColorEqualToColor(self.drawView.color.CGColor, [UIColor redColor].CGColor)) {
        colorNum = 1;
    }
    else  if (CGColorEqualToColor(self.drawView.color.CGColor, [UIColor blueColor].CGColor)  ){
        
        colorNum = 2;
    } else if (CGColorEqualToColor(self.drawView.color.CGColor, [UIColor greenColor].CGColor)  ) {
        colorNum = 3;
    }
    
    
    // 传递数据格式
    NSDictionary *pathDataDict = @{
                                   @"path" : tmp,
                                   @"width" : @(self.drawView.width),
                                   @"color" : @(colorNum),
                                   @"screenW": @([UIScreen mainScreen].bounds.size.width),
                                   @"screenH": @([UIScreen mainScreen].bounds.size.height)
                                   };
    
    NSData *pathData = [NSJSONSerialization
                        dataWithJSONObject:pathDataDict
                        options:NSJSONWritingPrettyPrinted
                        error:nil];
    
    
    [self.clientSocket emit:@"path" with:@[pathData]];
}

/*!
 @method  发送按钮的点击
 @abstract 通过socket 发送信息
 @param sender 发送按钮
 */
- (IBAction)sendMsgBtnClick:(id)sender {
    // 聊天信息
    if (self.chatTextField.text == nil || [self.chatTextField.text isEqualToString:@""]) {
        self.chatTextField.text = @"hello";
    }
    NSData *chatData = [self.chatTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.clientSocket emit:@"text" with:@[chatData]];
    
    self.chatTextField.text = @"";
    
    
}
#pragma mark - <UIImagePickerControllerDelegate>
/*!
 @method  系统方法，本地图片选择
 @abstract 本地图片选择
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    // 选中的图片
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    // 创建放大缩小图片选择编辑view
    DIYChoseImgView *bgImgView = [[DIYChoseImgView alloc]initWithFrame:self.drawView.frame];
    [self.view addSubview:bgImgView];
    
    // 回调 发送图片
    __weak typeof(self) weakSelf = self;
    bgImgView.block = ^(UIImage *img) {
        
        weakSelf.drawView.drawImg = img;
        // image --> base64
        NSData *imgData = UIImageJPEGRepresentation(weakSelf.drawView.drawImg, 0.2);
        
        NSString *base64 = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

//        // 拼接数据流的结束符
//        NSMutableString *dataString = [NSMutableString stringWithFormat:@"%@$", base64];
        // 直接发送即可
        // 发送数据
        [weakSelf.clientSocket emit:@"img" with:@[base64]];
        
    };

    bgImgView.img = selectedImg;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    

    
}
/*!
 @method  系统方法
 @abstract 本地图片选择,错误方法
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}


// path

- (void)receivePath {
    
    [self.clientSocket on:@"path" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        
        NSData *data = array.firstObject;
        
        NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:data
                                                                options:kNilOptions
                                                                  error:nil];
        
        // 1、接受坐标点
        NSInteger w = [tmpDict[@"screenW"] integerValue];
        NSInteger h = [tmpDict[@"screenH"] integerValue];
        CGFloat scaleW = [UIScreen mainScreen].bounds.size.width / w;
        CGFloat scaleH = [UIScreen mainScreen].bounds.size.height / h;
        // 处理点
        NSArray *pointDict = tmpDict[@"path"];
        DIYBezierPath *path = [[DIYBezierPath alloc]init];
        for (NSDictionary *tmpDict in pointDict) {
            CGPoint point = CGPointMake([tmpDict[@"x"] floatValue] * scaleW, [tmpDict[@"y"] floatValue] * scaleH);
            NSInteger index = [pointDict indexOfObject:tmpDict];
            if (index == 0) {
                [path moveToPoint:point];
            } else {
                [path addLineToPoint:point];
            }
            
        }
        switch ([tmpDict[@"color"] integerValue]) {
            case 0:
                self.drawView.color = [UIColor blackColor];
                break;
            case 1:
                self.drawView.color = [UIColor redColor];
                break;
            case 2:
                self.drawView.color = [UIColor blueColor];
                break;
            case 3:
                self.drawView.color = [UIColor greenColor];
                break;
                
            default:
                break;
        }
        self.drawView.width = [tmpDict[@"width"] floatValue];
        self.drawView.currentPath = path;
        self.drawView.currentPath.pathColor = self.drawView.color;
        self.drawView.currentPath.lineWidth = self.drawView.width;
        [self.drawView.pathArray addObject:path];
        [self.drawView setNeedsDisplay];
        
        
    }];
    
}

// img
- (void)receiveImg {
    
    [self.clientSocket on:@"img" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        
        NSString *data = array.firstObject;
        
        //        [self.socketReadData appendString:data];
        
        //        if ([self.socketReadData hasSuffix:@"$"]) {
        
        //            NSString *imgString = [self.socketReadData substringToIndex:self.socketReadData.length];
        
        NSData *imgData = [[NSData alloc]initWithBase64EncodedString:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        self.drawView.drawImg = [UIImage imageWithData:imgData];
        [self.drawView setNeedsDisplay];
            // 拼完图片 恢复默认
//            self.socketReadData = nil;
//        }
    }];
    
}
// text
- (void)receiveText {
    
    [self.clientSocket on:@"text" callback:^(NSArray * array, SocketAckEmitter * emitter) {
        
        
        NSData *data = array.firstObject;
        NSString *tmpStr = [[NSString alloc]initWithData:data
                                                encoding:NSUTF8StringEncoding];
        
        [self.chatArray addObject:tmpStr];
        [self.tableView reloadData];
        
        
        
        
    }];
    
    
}




#pragma mark - <UITextFieldDelegate>
/*!
 @method  系统方法
 @abstract 监听键盘Return键的点击
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.chatTextField resignFirstResponder];
    return YES;
}

#pragma mark - <UITableViewDataSource>
/*!
 @method  系统方法
 @abstract cell个数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatArray.count;
}
/*!
 @method  系统方法
 @abstract cell样式
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"chat"];
    }
    cell.textLabel.text = self.chatArray[indexPath.row];
    return cell;
    
}

@end
