//
//  CJUtilBridge.h
//  Runner
//
//  Created by chenyn on 2019/7/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJUtilBridge : NSObject

+ (void)bridgeCall:(FlutterMethodCall *)call
            result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
