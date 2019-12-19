//
//  CJMFRedPacketAttachment.h
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJCustomAttachmentDefines.h"

typedef NS_ENUM(NSInteger, MFRedPacketStatus){
    MFRedPacketStatusNormal = 0, //正常
    MFRedPacketStatusGot = 1,     // 已领取
    MFRedPacketStatusDue  = 2,    // 过期了
    MFRedPacketStatusNull = 3,    // 领完了
};

NS_ASSUME_NONNULL_BEGIN

@interface CJMFRedPacketAttachment : NSObject <CJCustomAttachment, CJCustomAttachmentInfo>

@property (nonatomic, copy) NSString *redPacketId;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

// 金额
@property (nonatomic, copy) NSString *money;

// 红包个数
@property (nonatomic,nonatomic) NSInteger count;

@property (nonatomic,nonatomic) MFRedPacketStatus  status;

@end

NS_ASSUME_NONNULL_END
