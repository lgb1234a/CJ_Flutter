//
//  CJMineViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
#import "CJScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CJScanViewController ()
<AVCaptureMetadataOutputObjectsDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
CJBoostViewController
>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, weak) UIImageView *line;
@property (nonatomic, assign) NSInteger distance;

@end

@implementation CJScanViewController

#pragma mark --- system api

- (instancetype)initWithBoostParams:(NSDictionary *)boost_params
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [UIViewController showMessage:@"请去->[设置-隐私一相机-默往]打开\n访问开关"
                           afterDelay:2.0];
    }
    //初始化信息
    [self initInfo];
    
    //创建控件
    [self creatControl];
    
    //设置参数
    [self setupCamera];
    
    //添加定时器
    [self addTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScanning];
}

- (void)initInfo
{
    //背景色
    self.view.backgroundColor = [UIColor blackColor];
    
    //导航标题
    self.navigationItem.title = @"扫一扫";
    //导航右侧相册按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(photoBtnOnClick)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnOnClick)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor yy_colorWithHexString:@"#3092EE"]];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor yy_colorWithHexString:@"#3092EE"]];
}

// 取消返回
- (void)backBtnOnClick
{
    [self.navigationController popViewControllerAnimated:true];
}

// 绘制UI
- (void)creatControl
{
    CGFloat scanW = SCREEN_WIDTH * 0.65;
    CGFloat padding = 10.0f;
    CGFloat labelH = 20.0f;
    CGFloat tabBarH = 64.0f;
    CGFloat cornerW = 26.0f;
    CGFloat marginX = (SCREEN_WIDTH - scanW) * 0.5;
    CGFloat marginY = (SCREEN_HEIGHT - scanW - padding - labelH) * 0.5;
    
    //遮盖视图
    for (int i = 0; i < 4; i++) {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, (marginY + scanW) * i, SCREEN_WIDTH, marginY + (padding + labelH) * i)];
        if (i == 2 || i == 3) {
            cover.frame = CGRectMake((marginX + scanW) * (i - 2), marginY, marginX, scanW);
        }
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.view addSubview:cover];
    }
    
    //扫描视图
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(marginX, marginY, scanW, scanW)];
    [self.view addSubview:scanView];
    
    //扫描线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanW, 2)];
    [self drawLineForImageView:line];
    [scanView addSubview:line];
    self.line = line;
    
    //边框
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scanW, scanW)];
    borderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    borderView.layer.borderWidth = 1.0f;
    [scanView addSubview:borderView];
    
    //扫描视图四个角
    for (int i = 0; i < 4; i++) {
        CGFloat imgViewX = (scanW - cornerW) * (i % 2);
        CGFloat imgViewY = (scanW - cornerW) * (i / 2);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, cornerW, cornerW)];
        if (i == 0 || i == 1) {
            imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI_2 * i);
        }else {
            imgView.transform = CGAffineTransformRotate(imgView.transform, - M_PI_2 * (i - 1));
        }
        [self drawImageForImageView:imgView];
        [scanView addSubview:imgView];
    }
    
    //提示标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanView.frame) + padding, SCREEN_WIDTH, labelH)];
    label.text = @"将二维码放入框内，即可自动扫描";
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    //选项栏
    UIView *tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - tabBarH, SCREEN_WIDTH, tabBarH)];
    tabBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self.view addSubview:tabBarView];
    
    //开启照明按钮
    UIButton *lightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0-50, CGRectGetMaxY(scanView.frame) + padding+20, 100, tabBarH)];
    lightBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [lightBtn setTitle:@"开启照明" forState:UIControlStateNormal];
    [lightBtn setTitle:@"关闭照明" forState:UIControlStateSelected];
    [lightBtn addTarget:self action:@selector(lightBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];
    
    UIButton *codeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, 0, 100, tabBarH)];
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [codeBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
    [codeBtn setTitle:@"我的二维码" forState:UIControlStateSelected];
    [codeBtn addTarget:self action:@selector(codeBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [tabBarView addSubview:codeBtn];
}

/// 跳转我的二维码页面
- (void)codeBtnOnClick:(UIButton *)btn
{
    NSString *userId = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSString *contentUrl = [NSString stringWithFormat:@"https://api.youxi2018.cn/v2/jump/p/%@", userId];
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:userId option:nil];
    [FlutterBoostPlugin open:@"qrcode"
                   urlParams:@{@"content": contentUrl,
                               @"embeddedImgAssetPath": info.avatarUrlString?:@"images/icon_contact_groupchat@2x.png"}
                        exts:@{@"animated": @(YES)}
              onPageFinished:^(NSDictionary *finish) {}
                  completion:^(BOOL c) {}];
}

// 相机配置
- (void)setupCamera
{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //初始化相机设备
        wself.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //初始化输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:wself.device error:nil];
        
        //初始化输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理，主线程刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        wself.session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [wself.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        if ([wself.session canAddInput:input]) [wself.session addInput:input];
        if ([wself.session canAddOutput:output]) [wself.session addOutput:output];
        
        //条码类型（二维码/条形码）
        output.metadataObjectTypes = output.availableMetadataObjectTypes;
        
        //更新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.preview = [AVCaptureVideoPreviewLayer layerWithSession:wself.session];
            wself.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            wself.preview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.view.layer insertSublayer:wself.preview atIndex:0];
            [wself.session startRunning];
        });
    });
}

// 定时器
- (void)addTimer
{
    _distance = 0;
    if(self.timer==NULL)
    {
        __weak typeof(self) wself = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (wself.distance++ > SCREEN_WIDTH * 0.65) wself.distance = 0;
            wself.line.frame = CGRectMake(0, wself.distance, SCREEN_WIDTH * 0.65, 2);
        }];
    }
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

//照明按钮点击事件
- (void)lightBtnOnClick:(UIButton *)btn
{
    //判断是否有闪光灯
    if (![_device hasTorch]) {
        [self showAlertWithTitle:@"当前设备没有闪光灯，无法开启照明功能" message:nil sureHandler:nil cancelHandler:nil];
        return;
    }
    
    btn.selected = !btn.selected;
    
    [_device lockForConfiguration:nil];
    if (btn.selected) {
        [_device setTorchMode:AVCaptureTorchModeOn];
    }else {
        [_device setTorchMode:AVCaptureTorchModeOff];
    }
    [_device unlockForConfiguration];
}

//进入相册
- (void)photoBtnOnClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }else {
        [self showAlertWithTitle:@"当前设备不支持访问相册" message:nil sureHandler:nil cancelHandler:nil];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描完成
    if ([metadataObjects count] > 0) {
        id obj = [metadataObjects firstObject];
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            //停止扫描
            [self stopScanning];
            //显示结果
            NSString *codeStr = [[metadataObjects firstObject] stringValue];
            [self judeIsLegal:codeStr];
        }
    }else
    {
        [self showAlertWithTitle:@"没有识别到二维码" message:nil sureHandler:nil cancelHandler:nil];
    }
}

- (void)startScanning
{
    @try {
        [_session startRunning];
        [self addTimer];
    } @catch (NSException *exception) {}
}

- (void)stopScanning
{
    [_session stopRunning];
    [self removeTimer];
}

#pragma mark - UIImagePickerControllrDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //获取相册图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        //识别图片
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        
        //识别结果
        if (features.count > 0) {
             CIQRCodeFeature *feature = [features objectAtIndex:0];
            [self judeIsLegal:feature.messageString];
      
        }else{
            [UIViewController showError:@"无法识别的二维码"];
        }
    }];
}

// 扫一扫 识别二维码
-(void)judeIsLegal:(NSString*)codeStr
{
    NSArray *codeArr;
    NSArray *array = [codeStr componentsSeparatedByString:@"jump/"];
    if(array.count!=2)
    {
        codeArr = array;
    }
    else
    {
        codeArr = [[array objectAtIndex:1] componentsSeparatedByString:@"/"];
    }
    
    if(codeArr.count!=2)
    {/// 是否是链接
        BOOL isUrl = [self isWebUrlString:codeStr];
        if (isUrl) {
            NSURLComponents *components = [[NSURLComponents alloc] initWithString:codeStr];
            if (components)
            {
                if (!components.scheme)
                {
                    //默认添加 http
                    components.scheme = @"http";
                }
                [[UIApplication sharedApplication] openURL:[components URL]];
            }
        }
        else
        {
            [UIViewController showError:[NSString stringWithFormat:@"无法识别的二维码:%@", codeStr]];
        }
    }
    else
    {
        NSString* accstr = [codeArr objectAtIndex:1];
        NSString* typestr = [codeArr objectAtIndex:0];
        if([typestr isEqualToString:@"p"]){
            if(cj_empty_string(accstr)) {
                [UIViewController showError:@"用户id不能为空"];
                return;
            }
            [FlutterBoostPlugin open:@"user_info"
                           urlParams:@{@"user_id": accstr}
                                exts:@{@"animated": @(YES)}
                      onPageFinished:^(NSDictionary *finish) {}
                          completion:^(BOOL c) {}];
        }
        else if([typestr isEqualToString:@"g"])
        {
            [self joinTeam:accstr];
        }
        else
        {
            [UIViewController showError:[NSString stringWithFormat:@"无法识别的二维码:%@", codeStr]];
        }
    }
}

// 加入群
- (void)joinTeam:(NSString *)teamId
{
    if(teamId == nil)
    {
        [UIViewController showError:@"群id不能为空"];
        return;
    }
    
    [FlutterBoostPlugin open:@"team_join_verify"
         urlParams:@{@"teamId": teamId}
              exts:@{@"animated": @(YES)}
    onPageFinished:^(NSDictionary *finish) {}
        completion:^(BOOL c) {}];
}

//提示弹窗
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               sureHandler:(void (^)(UIAlertAction *action))sureHandler
             cancelHandler:(void (^)(UIAlertAction *action))cancelHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:sureHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancelHandler];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//绘制角图片
- (void)drawImageForImageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.bounds.size);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(context, 6.0f);
    //设置颜色
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    //路径
    CGContextBeginPath(context);
    //设置起点坐标
    CGContextMoveToPoint(context, 0, imageView.bounds.size.height);
    //设置下一个点坐标
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, imageView.bounds.size.width, 0);
    //渲染，连接起点和下一个坐标点
    CGContextStrokePath(context);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

//绘制线图片
- (void)drawLineForImageView:(UIImageView *)imageView
{
    CGSize size = imageView.bounds.size;
    UIGraphicsBeginImageContext(size);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建一个颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //设置开始颜色
    const CGFloat *startColorComponents = CGColorGetComponents([[UIColor greenColor] CGColor]);
    //设置结束颜色
    const CGFloat *endColorComponents = CGColorGetComponents([[UIColor whiteColor] CGColor]);
    //颜色分量的强度值数组
    CGFloat components[8] = {startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]
    };
    //渐变系数数组
    CGFloat locations[] = {0.0, 1.0};
    //创建渐变对象
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    //绘制渐变
    CGContextDrawRadialGradient(context, gradient, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.25, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.5, kCGGradientDrawsBeforeStartLocation);
    //释放
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/// 判断是不是链接
- (BOOL)isWebUrlString:(NSString *)url
{
    NSString *scheme = nil;
    if (url == nil || [url isEqualToString:@""]) {
        return  NO;
    }
    // 去掉空格
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (url != nil) && (url.length != 0) ) {
        NSRange  urlRange = [url rangeOfString:@"://"];
        if (urlRange.location == NSNotFound) {
            // 判断是不是www.开头
            NSRange  urlRange1 = [url rangeOfString:@"www."];
            if (urlRange1.location == NSNotFound) {
                return NO;
            }
            else
                return YES;
        } else {
            scheme = [url substringWithRange:NSMakeRange(0, urlRange.location)];
            if (scheme == nil) {
                return  NO;
            }
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

@end

