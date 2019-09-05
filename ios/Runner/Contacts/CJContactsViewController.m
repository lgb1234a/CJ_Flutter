//
//  CJContactsViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  通讯录

#import "CJContactsViewController.h"

@interface CJContactsViewController ()

@end

@implementation CJContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *contactsOpenUrl = @"{\"route\":\"contacts\",\"channel_name\":\"com.zqtd.cajian/contacts\"}";
    [self setInitialRoute:contactsOpenUrl];
    
    self.navigationController.navigationBar.hidden = YES;
}



@end
