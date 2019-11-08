//
//  CJContactsViewController.m
//  Runner
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  通讯录

#import "CJContactsViewController.h"
#import "CJSessionViewController.h"

@interface CJContactsViewController ()

@end

@implementation CJContactsViewController

- (instancetype)init
{
    int bottomPadding = BOTTOM_BAR_HEIGHT + (ISPROFILEDSCREEN?UNSAFE_BOTTOM_HEIGHT:0);
    NSString *contactsOpenUrl = [NSString stringWithFormat:@"{\"route\":\"contacts\",\"channel_name\":\"com.zqtd.cajian/contacts\",\"params\":{\"bottom_padding\":\"%d\"}}", bottomPadding];
    self = [super initWithFlutterOpenUrl:contactsOpenUrl];
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

- (void)createSession:(NSArray *)params
{
    NSString *sessionId = params.firstObject;
    NSNumber *type = params[1];
    
    NIMSession *session = [NIMSession session:sessionId type:type.integerValue];
    CJSessionViewController *sessionVC = [[CJSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:sessionVC
                                         animated:YES];
}


@end
