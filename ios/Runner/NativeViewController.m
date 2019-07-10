//
//  NativeViewController.m
//  Runner
//
//  Created by chenyn on 2019/7/3.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NativeViewController.h"
#import <flutter_boost/FlutterBoostPlugin.h>
#import "CJRouter.h"

@interface NativeViewController ()

@end

@implementation NativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)pushFlutterPage:(id)sender {
    [CJRouter.sharedRouter openPage:@"first" params:@{} animated:YES completion:^(BOOL f){
        [FlutterBoostPlugin.sharedInstance onResultForKey:@"result_id_100" resultData:@{} params:@{}];
    }];
}

- (IBAction)present:(id)sender {
    [CJRouter.sharedRouter openPage:@"second" params:@{@"present":@(YES)} animated:YES completion:^(BOOL f){}];
    //    [self dismissViewControllerAnimated:YES completion:completion];
}

@end
