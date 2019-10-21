//
//  CJSessionInfoViewController.m
//  Runner
//
//  Created by chenyn on 2019/10/21.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  聊天信息页

#import "CJSessionInfoViewController.h"

@interface CJSessionInfoViewController ()

@property (nonatomic, strong) NIMSession *mSession;

@end

@implementation CJSessionInfoViewController

- (instancetype)initWithSession:(NIMSession *)session
{
    _mSession = session;
    NSString *sessionInfoOpenUrl = [NSString stringWithFormat:@"{\"route\":\"session_info\",\"channel_name\":\"com.zqtd.cajian/session_info\",\"params\":{\"id\":\"%@\",\"type\":\"%ld\"}}", session.sessionId, session.sessionType];
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

@end
