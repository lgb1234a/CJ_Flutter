//
//  CJContactSettingViewController.m
//  Runner
//
//  Created by chenyn on 2019/11/8.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  联系人设置页

#import "CJContactSettingViewController.h"

@interface CJContactSettingViewController ()

@end

@implementation CJContactSettingViewController

- (instancetype)initWithUserId:(NSString *)userId
{
    NSString *contactsOpenUrl = [NSString stringWithFormat:@"{\"route\":\"contact_setting\",\"channel_name\":\"com.zqtd.cajian/contact_setting\",\"params\":{\"user_id\":\"%@\"}}", userId];
    self = [super initWithFlutterOpenUrl:contactsOpenUrl];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
