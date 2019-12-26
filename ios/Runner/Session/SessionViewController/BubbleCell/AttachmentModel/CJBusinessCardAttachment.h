//
//  CJBusinessCardAttachment.h
//  Runner
//
//  Created by chenyn on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJCustomAttachmentDefines.h"

@class CJShareBusinessCardModel;

NS_ASSUME_NONNULL_BEGIN

@interface CJBusinessCardAttachment : NSObject <CJCustomAttachment, CJCustomAttachmentInfo>

/// 用户id
@property (nonatomic, copy) NSString *accid;

/// 昵称
@property (nonatomic, copy) NSString *nickName;

/// 头像
@property (nonatomic, copy) NSString *imageUrl;


- (instancetype)initWithShareModel:(CJShareBusinessCardModel *)model;

@end

NS_ASSUME_NONNULL_END
