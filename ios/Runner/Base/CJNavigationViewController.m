//
//  CJNavigationViewController.m
//  Runner
//
//  Created by chenyn on 2019/9/9.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNavigationViewController.h"

@interface CJNavigationViewController ()

@end

@implementation CJNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
