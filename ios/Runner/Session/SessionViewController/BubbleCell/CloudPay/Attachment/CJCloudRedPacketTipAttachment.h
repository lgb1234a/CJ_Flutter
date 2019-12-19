//
//  CJCloudRedPacketTipAttachment.h
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJCustomAttachmentDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJCloudRedPacketTipAttachment : NSObject <CJCustomAttachment, CJCustomAttachmentInfo>

/**
 红包发送者ID
 */
@property (nonatomic, strong) NSString * sendPacketId;
/**
 拆红包的人的ID
 */
@property (nonatomic, strong) NSString * openPacketId;

/**
 *  红包ID
 */
@property (nonatomic, strong) NSString * packetId;

/**
 是否为最后一个红包
 */
@property (nonatomic, strong) NSString * isGetDone;

@end

NS_ASSUME_NONNULL_END
