//
//  CJPayManager.m
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJPayManager.h"
#import <YouXiPayUISDK/ZZPayUI.h>

@interface CJPayManager ()

@end

@implementation CJPayManager

+ (instancetype)sharedManager
{
    static CJPayManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CJPayManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)didLogin
{
    // 初始化易红包服务
    NSString *key = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    [ZZPayUI initializePaySDKWithMerchantNo:@"yxcajian" userNo:key];
}

- (void)didLogout
{
    // 易红包注销
    [ZZPayUI didLogout];
}


@end
