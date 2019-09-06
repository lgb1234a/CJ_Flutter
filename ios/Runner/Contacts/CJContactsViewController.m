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
    int bottomPadding = BOTTOM_BAR_HEIGHT + (ISPROFILEDSCREEN?UNSAFE_BOTTOM_HEIGHT:0);
    NSString *contactsOpenUrl = [NSString stringWithFormat:@"{\"route\":\"contacts\",\"channel_name\":\"com.zqtd.cajian/contacts\",\"params\":{\"bottom_padding\":\"%d\"}}", bottomPadding];
    [self setInitialRoute:contactsOpenUrl];
    
    self.navigationController.navigationBar.hidden = YES;
}



@end
