//
//  CJLoginViewController.m
//  Runner
//
//  Created by chenyn on 2019/11/13.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJLoginViewController.h"

@interface CJLoginViewController ()

@end

@implementation CJLoginViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setName:@"login"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cj_rootNavigationController().navigationBarHidden = YES;
}

@end
