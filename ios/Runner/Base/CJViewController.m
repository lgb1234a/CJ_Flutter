//
//  CJViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJViewController.h"
#import <WXApi.h>

@interface CJViewController ()
<WXApiDelegate>

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
            ZZLog(@"flutter call :%@", call.method);
            SEL callMethod = NSSelectorFromString(call.method);
            if([self respondsToSelector:callMethod]) {
                [self performSelector:callMethod withObject:params afterDelay:0];
            }else {
                NSString *errorInfo = [NSString stringWithFormat:@"CJViewController未实现%@", call.method];
                NSAssert(NO, errorInfo);
            }
        }];
        
        // 渲染完成
        [self setFlutterViewDidRenderCallback:^{
//            [mc invokeMethod:@"会在widget build完成之后调用" arguments:nil];
        }];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ZZLog(@"view did load --- 会在widget build开始之前调用");
}

#pragma mark --- wx login
- (void)wxlogin
{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq* req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"get_access_token";
        [WXApi sendReq:req];
    }else{
        SendAuthReq* req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"get_access_token";
        req.openID = @"wx0f56e7c5e6daa01a";
        [WXApi sendAuthReq:req viewController:self delegate:self];
    }
}

@end
