//
//  CJMineViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJMineViewController.h"

@interface CJMineViewController ()

@end

@implementation CJMineViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setName:@"mine"];
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
