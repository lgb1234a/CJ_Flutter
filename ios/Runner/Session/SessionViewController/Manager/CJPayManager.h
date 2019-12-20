//
//  CJPayManager.h
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  擦肩：发红包，转账等支付相关逻辑

#import <Foundation/Foundation.h>
#import "JRMFHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJPayManager : NSObject

@property (nonatomic, copy, readonly) NSString *mfPartnerId;
@property (nonatomic, copy, readonly) NSString *mfPpartnerKey;
@property (nonatomic, copy, readonly) NSString * mfThirdToken;

+ (instancetype)sharedManager;

- (void)didLogout;

- (void)didLogin;

@end

NS_ASSUME_NONNULL_END
