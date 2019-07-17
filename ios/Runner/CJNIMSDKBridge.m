//
//  CJNIMSDKBridge.m
//  Runner
//
//  Created by chenyn on 2019/7/16.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNIMSDKBridge.h"
#import <NIMSDK/NIMSDK.h>

static FlutterMethodCall *_call = nil;
static FlutterResult _result = nil;

@interface CJNIMSDKBridge ()

@property (nonatomic, strong, class) FlutterMethodCall *call;
@property (nonatomic, copy, class) FlutterResult result;

@end

@implementation CJNIMSDKBridge

@dynamic call;
@dynamic result;

+ (FlutterMethodCall *)call
{
    return _call;
}

+ (void)setCall:(FlutterMethodCall *)call
{
    _call = call;
}

+ (FlutterResult)result
{
    return _result;
}

+ (void)setResult:(FlutterResult)result
{
    _result = result;
}


+ (void)bridgeCall:(FlutterMethodCall *)call
            result:(FlutterResult)result
{
    _call = call;
    _result = result;
    
    // flutter 调用
    NSLog(@"flutter call :%@", call.method);
    NSArray *params = call.arguments;
    SEL callMethod = NSSelectorFromString(call.method);
    [self performSelector:callMethod withObject:params afterDelay:0];
}

+ (void)registerSDK
{
#ifdef DEBUG
    static NSString *ApnsCername = @"cajiandev";
#else
    static NSString *ApnsCername = @"cajiandis";
#endif
    NSString *appKey        = @"0cc61ff22dda75b52c0e922e59d1077e";
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername      = ApnsCername;
    option.pkCername        = @"DEMO_PUSH_KIT";
    [[NIMSDK sharedSDK] registerWithOption:option];
}

// 登录云信sdk
+ (void)doLogin:(NSArray *)params
{
    [[NIMSDK sharedSDK].loginManager login:params.firstObject token:params[1] completion:^(NSError * _Nullable error) {
        if(!error) {
            NSLog(@"云信登录成功");
            CJNIMSDKBridge.result(@(YES));
        }else {
            NSLog(@"%@", error);
            CJNIMSDKBridge.result(@(NO));
        }
    }];
}

@end
