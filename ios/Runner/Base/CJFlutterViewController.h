//
//  CJViewController.h
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

@protocol CJBoostViewController <NSObject>

@required
- (instancetype)initWithBoostParams:(NSDictionary *)boost_params;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CJFlutterViewController : FLBFlutterViewContainer

@end

NS_ASSUME_NONNULL_END
