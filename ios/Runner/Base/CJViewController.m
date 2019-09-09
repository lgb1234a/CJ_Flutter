//
//  CJViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJViewController.h"
#include "GeneratedPluginRegistrant.h"
#import "CJUtilBridge.h"

@interface CJViewController ()

@property (nonatomic, strong) FlutterMethodChannel *mc;
@property (nonatomic, strong) FlutterMethodChannel *utilChannel;

@end

@implementation CJViewController

- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl
{
    self = [super initWithProject:nil
                          nibName:nil
                           bundle:nil];
    if(self) {
        [self setInitialRoute:openUrl];
        [self registerChannel];
        
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

/// util 
- (void)registerChannel
{
    __weak typeof(self) weakSelf = self;
    
    _utilChannel = [FlutterMethodChannel
                    methodChannelWithName:@"com.zqtd.cajian/util"
                    binaryMessenger:self.engine.binaryMessenger];
    
    [_utilChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        SEL callMethod = NSSelectorFromString(call.method);
        if([weakSelf respondsToSelector:callMethod])
        {
            [weakSelf performSelector:callMethod
                           withObject:call.arguments
                           afterDelay:0];
        }else {
            [CJUtilBridge bridgeCall:call result:result];
        }
    }];
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

- (void)dealloc
{
    ZZLog(@"%@ - dealloced!", NSStringFromClass(self.class));
}

@end
