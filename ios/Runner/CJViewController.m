//
//  CJViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJViewController.h"

@interface CJViewController ()

@end

@implementation CJViewController

- (instancetype)initWithInitialOpenUrl:(NSString *)openUrl
{
    self = [super initWithProject:nil
                          nibName:nil
                           bundle:nil];
    if(self) {
        [self setInitialRoute:openUrl];
        
        NSDictionary *params = [NSDictionary cj_dictionary:openUrl];
        // 设置回调
        FlutterMethodChannel *mc = [FlutterMethodChannel methodChannelWithName:params[@"channel_name"] binaryMessenger:self.engine.binaryMessenger];
        [mc setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            ZZLog(@"%@", call.method);
        }];
        
        // 渲染完成
        [self setFlutterViewDidRenderCallback:^{
//            [mc invokeMethod:@"初始化Flutter vc完成" arguments:nil];
        }];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ZZLog(@"view did load");
}

@end
