//
//  CJMoreContainerConfig.h
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJMoreContainerConfig : NSObject <NIMSessionConfig>

@property (nonatomic,strong) NIMSession *session;

@end

NS_ASSUME_NONNULL_END
