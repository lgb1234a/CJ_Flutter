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
#import "CJChatSelectViewController.h"
#import "CJShareAlertViewController.h"

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

@interface CJUtilBridge () <CJChatSelectResult, CJShareAlertResult>

@end

@implementation CJUtilBridge

- (void)initBridge
{
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
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self saveImageToAlbum:arguments];
    } forName:@"saveImageToAlbum"];
    
    [FlutterBoostPlugin.sharedInstance addEventListener:^(NSString *name, NSDictionary *arguments) {
        [self share:arguments];
    } forName:@"share"];
}

// 跳转聊天
- (void)sendMessage:(NSDictionary *)params
{
    NSString *sessionId = params[@"id"];
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
            if(!error && teamId) {
                // 关闭选择器
                [weakNav dismissViewControllerAnimated:YES completion:nil];
                [self sendMessage:@{@"id": teamId, @"type": @1}];
            }else {
                [UIViewController showError:@"创建群聊失败!"];
            }
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

/// 保存图片到相册
- (void)saveImageToAlbum:(NSDictionary *)params
{
    FlutterStandardTypedData *imgData = params[@"img_data"];
    UIImage *image = [[UIImage alloc] initWithData:imgData.data];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

/// 分享
- (void)share:(NSDictionary *)shareData
{
    /// type:  0-text  1-image 2-link
    NSInteger type = [shareData[@"type"] integerValue];
    if(type == 0 || type == 1) {
        // 分享文本 、 图片
        CJChatSelectViewController *chatSelectVC = [CJChatSelectViewController viewControllerWithDelegate:self];
        
        CJNavigationViewController *navController = [[CJNavigationViewController alloc] initWithRootViewController:chatSelectVC];
        [cj_rootNavigationController() presentViewController:navController
                                                    animated:YES
                                                  completion:nil];
        
        chatSelectVC.completion = ^(NIMSession * _Nonnull session) {
            
            // share alert
            [self shareAlert:shareData session:session];
        };
    }else if(type == 2) {
        
    }
}

#pragma mark ----- private ----
- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if(error) {
        [UIViewController showError:@"图片保存失败"];
    }else {
        [UIViewController showSuccess:@"图片保存成功"];
    }
}

- (void)shareAlert:(NSDictionary *)shareData
           session:(NIMSession *)session
{
    NSInteger type = [shareData[@"type"] integerValue];
    CJShareModel *model;
    if(type == 0) {
        model = [CJShareTextModel new];
        
    }else if(type == 1) {
        model = [CJShareImageModel new];
        FlutterStandardTypedData *imgData = shareData[@"imgData"];
        ((CJShareImageModel*)model).imageData = imgData.data;
    }
    
    CJShareAlertViewController *alertVC =
            [CJShareAlertViewController viewControllerWithSession:session
                                                      shareObject:model
                                                      forwordImpl:self];
    [cj_rootNavigationController() presentViewController:alertVC
                                                animated:YES
                                              completion:nil];
}

#pragma mark --- delegate ---

// 选择了一个会话
- (void)didSelectedSession:(NIMRecentSession *)rcntSession
                      from:(CJChatSelectViewController *)vc
{
    [vc.navigationController dismissViewControllerAnimated:YES completion:^{
        vc.completion(rcntSession.session);
    }];
}

// 创建新的群聊
- (void)shareToNewSession:(NIMSession *)session from:(CJChatSelectViewController *)vc
{
    [vc.navigationController dismissViewControllerAnimated:YES completion:^{
        vc.completion(session);
    }];
}

/// 转发
- (void)shouldForword:(CJShareModel *)model session:(NIMSession *)session
{
    CJSessionViewController *sessionVC = [[CJSessionViewController alloc] initWithSession:session];
    sessionVC.shareModel = model;
    [cj_rootNavigationController() pushViewController:sessionVC
                                             animated:YES];
}

@end
