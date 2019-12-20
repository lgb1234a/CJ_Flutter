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
{
    NSString *_thirdToken;
}

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
    // 初始化云红包服务
    if(cj_empty_string([JRMFSington GetPacketSington].MFThirdToken)) {
        co_launch(^{
            BaseModel *model = await([self requestJrmfToken]);
            [JRMFSington GetPacketSington].MFThirdToken = model.data;
            if(model.success) {
                [MFPacket instanceMFPacketWithPartnerId:self.mfPartnerId
                                           EnvelopeName:@"云红包"
                                        aliPaySchemeUrl:@"alipay052969"
                                        weChatSchemeUrl:CJWxAppKey
                                          customerClass:@"UserInfoModel"
                                           dynamicToken:NO
                                              appMothod:YES];
                
                [MFWallet instanceMFWalletSDKWithPartnerId:self.mfPartnerId AppMethod:YES];
            }
        });
    }
}

/// 获取金融魔方token
- (COPromise *)requestJrmfToken
{
    COPromise *p = [COPromise promise];
    NSString *accid = [[NIMSDK sharedSDK].loginManager currentAccount];
    BaseModel *model = await([HttpHelper post:@"https://api.youxi2018.cn/g2/lq/token/get" params:@{@"user_id": accid}]);
    
    if(co_getError()) {
        [UIViewController showError:@"网络开小差了~"];
        [p reject:co_getError()];
    }else {
        if(model.success) {
            [p fulfill:model];
        }else {
            NSString* errmsg = model.errmsg;
            if (cj_empty_string(errmsg)) {
                errmsg = @"红包服务维护中，请稍后重试！";
            }
            [UIViewController showError:errmsg];
            [p reject:[NSError new]];
        }
    }
    
    return p;
}

- (void)didLogout
{
    // 易红包注销
    [ZZPayUI didLogout];
}


- (NSString *)mfPartnerId
{
    return @"cjbank";
}

- (NSString *)mfPpartnerKey
{
    return @"";
}

@end
