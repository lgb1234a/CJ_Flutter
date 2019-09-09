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
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
