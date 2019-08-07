//
//  NSString+Cajian.h
//  Runner
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Cajian)

- (NSString *)urlDecodedString;

- (NSString *)MD5String;

- (id)jsonStringToDictionaryOrArray;

+ (NSString *)dictionaryOrArrayToJson:(id)params;

@end

NS_ASSUME_NONNULL_END
