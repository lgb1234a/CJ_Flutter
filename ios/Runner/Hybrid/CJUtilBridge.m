//
//  CJUtilBridge.m
//  Runner
//
//  Created by chenyn on 2019/7/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJUtilBridge.h"
#import <MBProgressHUD.h>

static FlutterMethodCall *_call = nil;
static FlutterResult _result = nil;

@interface CJUtilBridge ()
@property (nonatomic, strong, class) FlutterMethodCall *call;
@property (nonatomic, copy, class) FlutterResult result;
@end

@implementation CJUtilBridge

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
    CJUtilBridge.call = call;
    CJUtilBridge.result = result;
    
    // flutter 调用
    ZZLog(@"flutter call :%@", call.method);
    NSArray *params = call.arguments;
    SEL callMethod = NSSelectorFromString(call.method);
    if([self respondsToSelector:callMethod]) {
        [self performSelector:callMethod withObject:params afterDelay:0];
    }else {
        NSString *errorInfo = [NSString stringWithFormat:@"CJUtilBridge未实现%@", call.method];
        NSAssert(NO, errorInfo);
    }
}

static inline UIWindow *getkeyWindow()
{
    if([UIApplication sharedApplication].keyWindow)
    {
        return [UIApplication sharedApplication].keyWindow;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    return [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, width, height)];
}

+ (void)showTip:(NSArray *)params
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow()];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow() animated:YES];
    }
    HUD.contentColor = [UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = params.firstObject;
    HUD.label.numberOfLines = 0;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:2];
}

+ (void)postNotification:(NSArray *)params
{
    NSString *name = params.firstObject;
    id userInfo = params.lastObject;
    [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                        object:nil
                                                      userInfo:userInfo];
}


@end
