//
//  CJTabbarController.m
//  Runner
//
//  Created by chenyn on 2019/11/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJTabbarController.h"
#import "CJMineViewController.h"
#import "CJContactsViewController.h"
#import "CJSessionListViewController.h"
#import <CJPopOverMenuView.h>
#import "CJUtilBridge.h"
#import <YouXiPayUISDK/YouXiPayUISDK.h>

@interface CJTabbarController ()

@end

@implementation CJTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"擦肩";
    
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add setImage:[UIImage imageNamed:@"icon_group_add"]
         forState:UIControlStateNormal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:add];
    self.navigationItem.rightBarButtonItem = item;
    
    [add addTarget:self
            action:@selector(showMore:)
  forControlEvents:UIControlEventTouchUpInside];
}

- (instancetype)initWithRootViewControllers
{
    self = [super init];
    if(self) {
        CJSessionListViewController *listVC = [[CJSessionListViewController alloc] init];
        listVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"擦肩"
                                                           image:[UIImage imageNamed:@"icon_message_normal"]
                                                   selectedImage:[UIImage imageNamed:@"icon_message_pressed"]];
        listVC.tabBarItem.tag = 0;
        
        CJContactsViewController *contactsVC = [[CJContactsViewController alloc] init];
        contactsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                           image:[UIImage imageNamed:@"icon_contact_normal"]
                                                   selectedImage:[UIImage imageNamed:@"icon_contact_pressed"]];
        contactsVC.tabBarItem.tag = 1;
        
        CJMineViewController *mineVC = [[CJMineViewController alloc] init];
        mineVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我"
                                                           image:[UIImage imageNamed:@"icon_setting_normal"]
                                                   selectedImage:[UIImage imageNamed:@"icon_setting_pressed"]];
        mineVC.tabBarItem.tag = 2;
        
        self.viewControllers = @[listVC, contactsVC, mineVC];
    }
    return self;
    
}


/// 选中更多
- (void)showMore:(UIButton *)sender
{
    CGRect rct = [sender convertRect:sender.bounds toView:nil];
    CGPoint startPoint = CGPointMake(rct.origin.x + rct.size.width*0.5,
                                     rct.origin.y + STATUS_BAR_HEIGHT);
    
    CJPopOverMenuView *menuView = [CJPopOverMenuView popover];
    menuView.didShowHandler = ^{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    };
    
    menuView.didDismissHandler = ^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    };
    
    CGFloat btnHeight = 40.f;
    CGFloat contentWidth = 130.f;
    UIView *contentView = [UIView new];
    
    /// 发起群聊
    UIButton *createGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    [createGroup.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [createGroup setTitle:@"发起聊天" forState:UIControlStateNormal];
    [createGroup setTitleColor:Main_TextBlackColor forState:UIControlStateNormal];
    createGroup.frame = CGRectMake(10, 0, contentWidth, btnHeight);
    [createGroup addTarget:self
                    action:@selector(createGroup:)
          forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:createGroup];
    [createGroup setImage:[UIImage imageNamed:@"icon_new_chat"]
                 forState:UIControlStateNormal];
    
    [createGroup setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    
    /// 分割线
    CALayer *line_1 = [CALayer layer];
    [line_1 setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
    [line_1 setFrame:CGRectMake(10, btnHeight, contentWidth - 10, 0.5)];
    [contentView.layer addSublayer:line_1];
    
    
    /// 添加好友
    UIButton *addFriend = [UIButton buttonWithType:UIButtonTypeCustom];
    [addFriend.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [addFriend setTitle:@"添加好友" forState:UIControlStateNormal];
    [addFriend setTitleColor:Main_TextBlackColor forState:UIControlStateNormal];
    addFriend.frame = CGRectMake(10, btnHeight*2, contentWidth, btnHeight);
    [addFriend addTarget:self
          action:@selector(addFriend:)
    forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:addFriend];
    [addFriend setImage:[UIImage imageNamed:@"icon_contact_add"]
               forState:UIControlStateNormal];
    
    [addFriend setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    
    /// 分割线
    CALayer *line_2 = [CALayer layer];
    [line_2 setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
    [line_2 setFrame:CGRectMake(10, btnHeight*2, contentWidth - 10, 0.5)];
    [contentView.layer addSublayer:line_2];
    
      /// 扫一扫
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [scanBtn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [scanBtn setTitleColor:Main_TextBlackColor forState:UIControlStateNormal];
    scanBtn.frame = CGRectMake(10, btnHeight, contentWidth, btnHeight);
    [scanBtn addTarget:self
          action:@selector(showScanView:)
    forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:scanBtn];
    [scanBtn setImage:[UIImage imageNamed:@"icon_scan"]
             forState:UIControlStateNormal];
    
    [scanBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -35, 0, 0)];
    [scanBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -14, 0, 0)];
    
    /// 分割线
    CALayer *line_3 = [CALayer layer];
    [line_3 setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
    [line_3 setFrame:CGRectMake(10, btnHeight*3, contentWidth - 10, 0.5)];
    [contentView.layer addSublayer:line_3];
    
    /// 我的钱包
    UIButton *walletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [walletBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [walletBtn setTitle:@"我的钱包" forState:UIControlStateNormal];
    [walletBtn setTitleColor:Main_TextBlackColor forState:UIControlStateNormal];
    walletBtn.frame = CGRectMake(10, btnHeight*3, contentWidth, btnHeight);
    [walletBtn addTarget:self
          action:@selector(showMyWallet:)
    forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:walletBtn];
    [walletBtn setImage:[UIImage imageNamed:@"icon_my_wallet"]
               forState:UIControlStateNormal];
    
    [walletBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    
    contentView.frame = CGRectMake(0, 0, contentWidth, btnHeight * 4);
    [menuView showAtPoint:startPoint
           popoverPostion:CJPopoverPositionDown
          withContentView:contentView
                   inView:self.view];
}


- (void)showScanView:(id)sender
{
    /// 打开扫一扫页面
    [FlutterBoostPlugin open:@"nativePage://android&iosPageName=CJScanViewController"
                   urlParams:@{}
                        exts:@{@"animated": @(YES)}
              onPageFinished:^(NSDictionary * _Nonnull d) {
        
    } completion:^(BOOL c) {
        
    }];
}


- (void)createGroup:(id)sender
{
    /// 发起聊天
    CJUtilBridge *bridge = [CJUtilBridge new];
    [bridge createGroupChat:@{@"user_ids": @[]}];
}

- (void)addFriend:(id)sender
{
    /// 跳转添加好友页
}

- (void)showMyWallet:(id)sender
{
    /// 拉起我的钱包页面
    [ZZPayUI showMyWallet:cj_rootNavigationController()];
}

@end
