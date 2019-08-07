//
//  UIViewController+HUD.h
//  CaJian
//
//  Created by TF_man on 2019/2/1.
//  Copyright © 2019年 Netease. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

typedef void(^completionBlock)(void);

@interface UIViewController (HUD)

+(void)showSuccess:(NSString *)success;

+(void)showError:(NSString *)error;

+(void)showMessage:(NSString *)message afterDelay:(NSTimeInterval)timer;

+(void)showMessage:(NSString *)message afterDelay:(NSTimeInterval)timer completion:(completionBlock)completion;

+(void)showWaiting;

+(void)showLoading;

+(void)showLoadingWithMessage:(NSString *)message;

+(void)showSaving;

+(void)hideHUD;

@end

NS_ASSUME_NONNULL_END
