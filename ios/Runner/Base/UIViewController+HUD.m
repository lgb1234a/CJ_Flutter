//
//  UIViewController+HUD.m
//  CaJian
//
//  Created by TF_man on 2019/2/1.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <MBProgressHUD.h>
#define kLastWindow [UIApplication sharedApplication].keyWindow

// 注册接口签名不一致
static inline UIWindow *getkeyWindow(UIWindow *window)
{
    if(window)
    {
        return window;
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
}

#import "UIViewController+HUD.h"


@implementation UIViewController (HUD)

+(void)showSuccess:(NSString *)success
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor = [UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    UIImage *image = [UIImage imageNamed:@"hud_success"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    HUD.customView = imageView;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = success;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:NO afterDelay:1];
    
}

+(void)showError:(NSString *)error
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor=[UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    UIImage *image = [UIImage imageNamed:@"hud_error"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    HUD.customView = imageView;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = error;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:1];
}

+(void)showMessage:(NSString *)message afterDelay:(NSTimeInterval)timer
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor=[UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = message;
    HUD.label.numberOfLines = 0;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:timer];
}
+(void)showMessage:(NSString *)message afterDelay:(NSTimeInterval)timer completion:(completionBlock)completion
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor=[UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = message;
    HUD.label.numberOfLines = 0;
    HUD.removeFromSuperViewOnHide=YES;
    [HUD hideAnimated:YES afterDelay:timer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timer * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
}
+(void)showWaiting{
    
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor = [UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.removeFromSuperViewOnHide = YES;
}

+(void)showLoading
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor=[UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.label.text = @"正在加载...";
    HUD.removeFromSuperViewOnHide = YES;
}
+(void)showLoadingWithMessage:(NSString *)message
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor=[UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.label.text = message;
    HUD.removeFromSuperViewOnHide = YES;
}
+(void)showSaving
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:getkeyWindow(kLastWindow)];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:getkeyWindow(kLastWindow) animated:YES];
    }
    HUD.contentColor = [UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.label.text = @"正在保存...";
    HUD.removeFromSuperViewOnHide = YES;
}

+(void)hideHUD
{
    [MBProgressHUD hideHUDForView:getkeyWindow(kLastWindow) animated:YES];
}

@end
