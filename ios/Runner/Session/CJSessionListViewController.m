//
//  CJSessionListViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJSessionListViewController.h"
#import "CJSessionViewController.h"

@interface CJSessionListViewController ()

@end

@implementation CJSessionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"擦肩";
}

#pragma mark - Override
- (void)onSelectedAvatar:(NSString *)userId
             atIndexPath:(NSIndexPath *)indexPath
{
    
};

- (void)onSelectedRecent:(NIMRecentSession *)recentSession atIndexPath:(NSIndexPath *)indexPath
{
    CJSessionViewController *vc = [[CJSessionViewController alloc] initWithSession:recentSession.session];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
