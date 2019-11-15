//
//  CJNavigationViewController.m
//  Runner
//
//  Created by chenyn on 2019/9/9.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNavigationViewController.h"
#import "CJFlutterViewController.h"

@interface CJNavigationViewController ()

@end

@implementation CJNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIModalPresentationStyle)modalPresentationStyle
{
    return UIModalPresentationFullScreen;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([viewController isKindOfClass:FLBFlutterViewContainer.class]) {
        self.navigationBar.hidden = YES;
    }else {
        self.navigationBar.hidden = NO;
    }
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *previous = self.viewControllers[self.viewControllers.count - 2];
    if([previous isKindOfClass:FLBFlutterViewContainer.class]) {
        self.navigationBar.hidden = YES;
    }else {
        self.navigationBar.hidden = NO;
    }
    return [super popViewControllerAnimated:animated];
}

@end
