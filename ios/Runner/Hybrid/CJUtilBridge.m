//
//  CJUtilBridge.m
//  Runner
//
//  Created by chenyn on 2019/7/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJUtilBridge.h"
#import <MBProgressHUD.h>
#import "CJSessionViewController.h"
#import "CJContactSelectViewController.h"

static inline UIWindow *cj_getkeyWindow()
{
    if([UIApplication sharedApplication].keyWindow)
    {
        return [UIApplication sharedApplication].keyWindow;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    return [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, width, height)];
}

@implementation CJUtilBridge

- (void)initBridge
{
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self sendMessage:arguments];
    } forName:@"sendMessage"];
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self createGroupChat:arguments];
    } forName:@"createGroupChat"];
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self showTip:arguments];
    } forName:@"showTip"];
    
//    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
//
//    } forName:@"showSheet"];
}

// 跳转聊天
- (void)sendMessage:(NSDictionary *)params
{
    NSString *sessionId = params[@"session_id"];
    NSNumber *type = params[@"type"];
    
    NIMSession *session = [NIMSession session:sessionId type:type.integerValue];
    CJSessionViewController *sessionVC = [[CJSessionViewController alloc] initWithSession:session];
    [cj_rootNavigationController() pushViewController:sessionVC
                                         animated:YES];
}

/// 创建群聊
/// @param params 群成员ids
- (void)createGroupChat:(NSDictionary *)params
{
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.type       = NIMTeamTypeAdvanced;
    option.joinMode   = NIMTeamJoinModeNoAuth;
    option.beInviteMode = NIMTeamBeInviteModeNoAuth;
    option.inviteMode   = NIMTeamInviteModeAll;
    
    NIMContactFriendSelectConfig *config = [NIMContactFriendSelectConfig new];
    config.needMutiSelected = YES;
    config.alreadySelectedMemberId = params[@"user_ids"];
    
    CJContactSelectViewController *selectorVc = [[CJContactSelectViewController alloc] initWithConfig:config];
    CJNavigationViewController *nav = [[CJNavigationViewController alloc] initWithRootViewController:selectorVc];
    
    __weak typeof(nav) weakNav = nav;
    selectorVc.finished = ^(NSArray <NSString *>*ids) {
        NSMutableArray *names = @[[[NIMKit sharedKit] infoByUser:[NIMSDK sharedSDK].loginManager.currentAccount option:nil].showName].mutableCopy;
        // 获取成员名字
        [ids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [names addObject:[[NIMKit sharedKit] infoByUser:obj option:nil].showName];
        }];
        
        option.name = [names componentsJoinedByString:@"、"];
        [[NIMSDK sharedSDK].teamManager createTeam:option
                                             users:ids
                                        completion:^(NSError * __nullable error, NSString * __nullable teamId, NSArray<NSString *> * __nullable failedUserIds){
            // 关闭选择器
            [weakNav dismissViewControllerAnimated:YES completion:nil];
            [self sendMessage:@{@"session_id": teamId, @"type": @1}];
        }];
    };
    
    [[FlutterBoostPlugin sharedInstance].currentViewController
                                    presentViewController:nav
                                                 animated:YES
                                               completion:nil];
}

- (void)showTip:(NSDictionary *)params
{
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:cj_getkeyWindow()];
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:cj_getkeyWindow() animated:YES];
    }
    HUD.contentColor = [UIColor whiteColor];
    HUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = params[@"text"];
    HUD.label.numberOfLines = 0;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:2];
}

//- (void)showSheet:(NSDictionary *)params
//{
//    NSString *title = params[@"title"];
//    NSString *message = params[@"message"];
//    NSInteger style = [params[@"style"] integerValue];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
//                                                                   message:message preferredStyle:style];
//
//
//}

@end
