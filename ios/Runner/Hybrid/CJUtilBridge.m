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
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self addContactsToTeam:arguments];
    } forName:@"addTeamMember"];
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self kickUserOutTeam:arguments];
    } forName:@"kickUserOutTeam"];
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self popToRootPage];
    } forName:@"popToRootPage"];
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


/// 提示信息
/// @param params 提示文案
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

/// 邀请联系人进群
/// @param params 群id
- (void)addContactsToTeam:(NSDictionary *)params
{
    NIMContactFriendSelectConfig *config = [NIMContactFriendSelectConfig new];
    config.needMutiSelected = YES;
    config.filterIds = params[@"filter_ids"];
    
    CJContactSelectViewController *selectorVc = [[CJContactSelectViewController alloc] initWithConfig:config];
    CJNavigationViewController *nav = [[CJNavigationViewController alloc] initWithRootViewController:selectorVc];
    
    __weak typeof(nav) weakNav = nav;
    __weak typeof(self) weakSelf = self;
    selectorVc.finished = ^(NSArray <NSString *>*ids)
    {
        [[NIMSDK sharedSDK].teamManager addUsers:ids
                                          toTeam:params[@"team_id"]
                                      postscript:nil
                                          attach:nil
                                      completion:^(NSError * _Nullable error, NSArray<NIMTeamMember *> * _Nullable members) {
            if(!error) {
                [weakSelf showTip:@{@"text": @"邀请成功"}];
                [[FlutterBoostPlugin sharedInstance] sendEvent:@"updateTeamMember"
                                                     arguments:@{@"name":@"邀请成功"}];
            }else {
                [weakSelf showTip:@{@"text": @"邀请失败"}];
            }
            // 关闭选择器
            [weakNav dismissViewControllerAnimated:YES completion:nil];
            
        }];
    };
    
    [[FlutterBoostPlugin sharedInstance].currentViewController
                                    presentViewController:nav
                                                 animated:YES
                                               completion:nil];
}


/// 踢出群聊
/// @param params 参数
- (void)kickUserOutTeam:(NSDictionary *)params
{
    NIMContactTeamMemberSelectConfig *config = [NIMContactTeamMemberSelectConfig new];
    config.needMutiSelected = YES;
    config.teamId = params[@"team_id"];
    
    CJContactSelectViewController *selectorVc = [[CJContactSelectViewController alloc] initWithConfig:config];
    CJNavigationViewController *nav = [[CJNavigationViewController alloc] initWithRootViewController:selectorVc];
    
    __weak typeof(nav) weakNav = nav;
    __weak typeof(self) weakSelf = self;
    selectorVc.finished = ^(NSArray <NSString *>*ids)
    {
        [[NIMSDK sharedSDK].teamManager kickUsers:ids
                                         fromTeam:config.teamId
                                       completion:^(NSError * _Nullable error) {
            // 关闭选择器
            [weakNav dismissViewControllerAnimated:YES completion:nil];
            if(!error) {
                [weakSelf showTip:@{@"text": @"踢人成功"}];
                [[FlutterBoostPlugin sharedInstance] sendEvent:@"updateTeamMember"
                                                     arguments:@{@"name":@"踢人成功"}];
            }else {
                [weakSelf showTip:@{@"text": @"踢人失败"}];
            }
            
        }];
    };
    
    [[FlutterBoostPlugin sharedInstance].currentViewController
                                    presentViewController:nav
                                                 animated:YES
                                               completion:nil];
}


/// 回到根视图
- (void)popToRootPage
{
    [cj_rootNavigationController() popToRootViewControllerAnimated:YES];
}

@end
