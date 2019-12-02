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

@interface CJTabbarController ()

@end

@implementation CJTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"擦肩";
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

@end
