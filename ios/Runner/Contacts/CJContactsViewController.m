//
//  CJContactsViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  通讯录

#import "CJContactsViewController.h"
#import "CJSessionViewController.h"

@interface CJContactsViewController ()

@end

@implementation CJContactsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        double bottomPadding = BOTTOM_BAR_HEIGHT + (ISPROFILEDSCREEN?UNSAFE_BOTTOM_HEIGHT:0);
        [self setName:@"contacts" params:@{@"bottom_padding": @(bottomPadding)}];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cj_rootNavigationController().navigationBarHidden = YES;
}

@end
