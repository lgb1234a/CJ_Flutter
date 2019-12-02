//
//  CJSessionViewController.h
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NIMSessionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJSessionViewController : NIMSessionViewController<CJBoostViewController>

- (instancetype)initWithBoostParams:(NSDictionary *)boost_params;

@end

NS_ASSUME_NONNULL_END
