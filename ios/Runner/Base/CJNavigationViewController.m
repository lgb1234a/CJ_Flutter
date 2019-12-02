//
//  CJNavigationViewController.m
//  Runner
//
//  Created by chenyn on 2019/9/9.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNavigationViewController.h"
#import "CJFlutterViewController.h"
#import "CJTabbarController.h"

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
    if([viewController isKindOfClass:FLBFlutterViewContainer.class])
    {
        self.navigationBarHidden = YES;
    }else if([viewController isKindOfClass:CJTabbarController.class])
    {
        // 根视图
        UIViewController *vc = ((CJTabbarController *)viewController).selectedViewController;
        self.navigationBarHidden = [vc isKindOfClass:FLBFlutterViewContainer.class];
    }else {
        self.navigationBarHidden = NO;
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
    if(self.viewControllers.count >= 2) {
        UIViewController *previous = self.viewControllers[self.viewControllers.count - 2];
        if([previous isKindOfClass:FLBFlutterViewContainer.class]) {
            self.navigationBarHidden = YES;
        }else if([previous isKindOfClass:CJTabbarController.class])
        {
            // 根视图
            UIViewController *vc = ((CJTabbarController *)previous).selectedViewController;
            self.navigationBarHidden = [vc isKindOfClass:FLBFlutterViewContainer.class];
        }
        else {
            self.navigationBarHidden = NO;
        }
    }
    
    return [super popViewControllerAnimated:animated];
}

@end
