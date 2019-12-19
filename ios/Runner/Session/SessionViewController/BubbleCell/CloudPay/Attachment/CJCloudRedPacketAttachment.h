//
//  CJCloudRedPacketAttachment.h
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJCustomAttachmentDefines.h"

typedef NS_ENUM(NSInteger, CloudRedPacketStatus){
    CloudRedPacketStatusNormal = 0, //正常
    CloudRedPacketStatusGot = 1,     // 已领取
    CloudRedPacketStatusDue  = 2,    // 过期了
    CloudRedPacketStatusNull = 3,    // 领完了
};

NS_ASSUME_NONNULL_BEGIN

@interface CJCloudRedPacketAttachment : NSObject <CJCustomAttachment, CJCustomAttachmentInfo>

@property (nonatomic, copy) NSString *redPacketId;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *money;        // 金额

@property (nonatomic,nonatomic) NSInteger count;        // 红包个数

@property (nonatomic,nonatomic) CloudRedPacketStatus  status ;    // 状态 0 正常 1灰色

@end

NS_ASSUME_NONNULL_END
