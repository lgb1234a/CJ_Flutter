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
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [btn setTitleColor:Main_TextBlackColor forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 80, 30);
    [btn addTarget:self
            action:@selector(showScanView:)
  forControlEvents:UIControlEventTouchUpInside];
    
    [menuView showAtPoint:startPoint
           popoverPostion:CJPopoverPositionDown
          withContentView:btn
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


@end
