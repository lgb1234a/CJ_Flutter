//
//  CJShareMsgInteractor.h
//  Runner
//
//  Created by chenyn on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  分享消息

#import <Foundation/Foundation.h>
#import "CJShareModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJShareMsgInteractor : NSObject

+ (void)shareModel:(CJShareModel *)model to:(NIMSession *)session;

@end

NS_ASSUME_NONNULL_END
