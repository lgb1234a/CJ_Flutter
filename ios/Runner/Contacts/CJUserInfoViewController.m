//
//  CJUserInfoViewController.m
//  Runner
//
//  Created by chenyn on 2019/11/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  个人信息页

#import "CJUserInfoViewController.h"
#import "CJContactSettingViewController.h"

@interface CJUserInfoViewController ()<UINavigationControllerDelegate>

@end

@implementation CJUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = self;
    self.title = @"详细资料";
    
    [self setUpNavBarItem];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController == self) {
        self.navigationController.navigationBar.hidden = NO;
    }
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

@end
