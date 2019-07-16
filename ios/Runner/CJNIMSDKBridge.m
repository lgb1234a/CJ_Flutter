//
//  CJNIMSDKBridge.m
//  Runner
//
//  Created by chenyn on 2019/7/16.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNIMSDKBridge.h"


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


+ (void)bridgeWithCall:(FlutterMethodCall *)call
                result:(FlutterResult)result
{
    _call = call;
    _result = result;
    
    // flutter 调用
    NSLog(@"flutter diaoyong :%@", call.method);
}


@end
