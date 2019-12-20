//
//  CJSessionViewController.h
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NIMSessionViewController.h"
#import "JRMFHeader.h"

@class CJShareModel;

NS_ASSUME_NONNULL_BEGIN

@interface CJSessionViewController : NIMSessionViewController<CJBoostViewController, MFManagerDelegate>

/// 分享的数据
@property (nonatomic, strong, nullable) CJShareModel *shareModel;

- (instancetype)initWithBoostParams:(NSDictionary *)boost_params;

@end

NS_ASSUME_NONNULL_END
