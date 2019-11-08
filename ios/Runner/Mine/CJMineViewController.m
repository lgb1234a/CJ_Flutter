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
    NSString *mineOpenUrl = @"{\"route\":\"mine\",\"channel_name\":\"com.zqtd.cajian/mine\"}";
    self = [super initWithFlutterOpenUrl:mineOpenUrl];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

@end
