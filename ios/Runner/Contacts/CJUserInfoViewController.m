//
//  CJUserInfoViewController.m
//  Runner
//
//  Created by chenyn on 2019/11/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  个人信息页

#import "CJUserInfoViewController.h"
#import "CJContactSettingViewController.h"
#import "CJContactSelectViewController.h"
#import "CJSessionViewController.h"

@interface CJUserInfoViewController ()

@end

@implementation CJUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详细资料";
    
    [self setUpNavBarItem];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)setUpNavBarItem
{
    UIButton *contactSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [contactSettingBtn addTarget:self action:@selector(contactSetting:) forControlEvents:UIControlEventTouchUpInside];
    [contactSettingBtn setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
    [contactSettingBtn setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
    [contactSettingBtn sizeToFit];
    
    UIBarButtonItem *enterTeamCardItem = [[UIBarButtonItem alloc] initWithCustomView:contactSettingBtn];
    
    self.navigationItem.rightBarButtonItems  = @[enterTeamCardItem];
}


// 联系人设置
- (void)contactSetting:(id)sender
{
    // 跳转联系人设置页
    NSString *userId = self.params[@"user_id"];
    CJContactSettingViewController *vc = [[CJContactSettingViewController alloc] initWithUserId:userId];
    
    [self.navigationController pushViewController:vc animated:YES];
}

// 发消息
- (void)sendMessage:(NSArray *)params
{
    NSString *userId = params.firstObject;
    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
    CJSessionViewController *sessionVC = [[CJSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:sessionVC animated:YES];
}

@end
