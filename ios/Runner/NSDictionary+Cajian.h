//
//  NSDictionary+Cajian.h
//  Runner
//
//  Created by chenyn on 2019/7/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Cajian)

+ (NSDictionary *)cj_dictionary:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
