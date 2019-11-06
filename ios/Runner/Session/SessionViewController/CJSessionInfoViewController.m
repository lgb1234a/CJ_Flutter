//
//  CJSessionInfoViewController.m
//  Runner
//
//  Created by chenyn on 2019/10/21.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  聊天信息页

#import "CJSessionInfoViewController.h"
#import "CJContactSelectViewController.h"
#import "CJSessionViewController.h"

@interface CJSessionInfoViewController ()

@property (nonatomic, strong) NIMSession *mSession;

@end

@implementation CJSessionInfoViewController

- (instancetype)initWithSession:(NIMSession *)session
{
    _mSession = session;
    NSString *sessionInfoOpenUrl = [NSString stringWithFormat:@"{\"route\":\"session_info\",\"channel_name\":\"com.zqtd.cajian/session_info\",\"params\":{\"id\":\"%@\",\"type\":%ld}}", session.sessionId, session.sessionType];
    self = [super initWithFlutterOpenUrl:sessionInfoOpenUrl];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(_mSession.sessionType == NIMSessionTypeP2P) {
        // 单聊
        self.title = @"聊天信息";
    }else {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByTeam:_mSession.sessionId option:nil];
        [[NIMSDK sharedSDK].teamManager fetchTeamInfo:_mSession.sessionId
                                           completion:^(NSError * _Nullable error, NIMTeam * _Nullable team)
        {
            self.title = [NSString stringWithFormat:@"%@(%ld)", info.showName, team.memberNumber];
        }];
    }
}

/// 创建群聊
/// @param params 群成员ids
- (void)createGroupChat:(NSArray *)params
{
    
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
//    option.name       = @"";
    option.type       = NIMTeamTypeAdvanced;
    option.joinMode   = NIMTeamJoinModeNoAuth;
    option.beInviteMode = NIMTeamBeInviteModeNoAuth;
    option.inviteMode   = NIMTeamInviteModeAll;
    
    NIMContactFriendSelectConfig *config = [NIMContactFriendSelectConfig new];
    config.needMutiSelected = YES;
    config.alreadySelectedMemberId = params;
    
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
            [weakNav dismissViewControllerAnimated:YES completion:^{
                if(error) {
                    [UIViewController showError:error.description];
                }else {
                    [self pushTeamViewController:teamId];
                }
            }];
        }];
    };
    
    [self.navigationController presentViewController:nav
                                            animated:YES
                                          completion:nil];
}

#pragma mark -------- private ---------

- (void)pushTeamViewController:(NSString *)teamId
{
    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
    CJSessionViewController *sessionVC = [[CJSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:sessionVC animated:YES];
}

@end
