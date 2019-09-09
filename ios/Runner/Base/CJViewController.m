//
//  CJViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJViewController.h"
#import <WXApi.h>
#include "GeneratedPluginRegistrant.h"

@interface CJViewController ()
<WXApiDelegate>

@end

@interface CJViewController ()

@property (nonatomic, strong) FlutterMethodChannel *mc;

@end

@implementation CJViewController

- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl
{
    self = [super initWithProject:nil
                          nibName:nil
                           bundle:nil];
    if(self) {
        [self setInitialRoute:openUrl];
        
        NSDictionary *params = [NSDictionary cj_dictionary:openUrl];
        // 设置回调
        _mc = [FlutterMethodChannel methodChannelWithName:params[@"channel_name"] binaryMessenger:self.engine.binaryMessenger];
        
        __weak typeof(self) wself = self;
        [_mc setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            ZZLog(@"flutter call :%@", call.method);
            SEL callMethod = NSSelectorFromString(call.method);
            if([wself respondsToSelector:callMethod]) {
                [wself performSelector:callMethod
                            withObject:call.arguments
                            afterDelay:0];
            }else {
                ZZLog(@"%@未实现%@", NSStringFromClass(wself.class), call.method);
            }
        }];
        
        // 渲染完成
        [self setFlutterViewDidRenderCallback:^{
//            [_mc invokeMethod:@"会在widget build完成之后调用" arguments:nil];
        }];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // (@"view did load --- 会在widget build开始之前调用");
    [GeneratedPluginRegistrant registerWithRegistry:self];
}

// 从flutter发来的push新页面操作
- (void)pushViewControllerWithOpenUrl:(NSArray *)params
{
    NSString *openUrl = params.firstObject;
    CJViewController *nextVc = [[CJViewController alloc] initWithFlutterOpenUrl:openUrl];
    [self.navigationController pushViewController:nextVc
                                         animated:YES];
}

// 推出当前页
- (void)popFlutterViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
