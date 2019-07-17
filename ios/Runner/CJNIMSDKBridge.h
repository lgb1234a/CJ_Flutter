//
//  CJNIMSDKBridge.h
//  Runner
//
//  Created by chenyn on 2019/7/16.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJNIMSDKBridge : NSObject

+ (void)bridgeCall:(FlutterMethodCall *)call
            result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
