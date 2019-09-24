//
//  CJYeePayRedPacketAtachment.h
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJCustomAttachmentDefines.h"

typedef NS_ENUM(NSInteger, CJYeeRedPacketStatus){
    // 0. 待领取  1.部分被领取  2.被领取  3.超时已退款
    CJYeeRedPacketStatusNormal = 0, //正常
    CJYeeRedPacketStatusGot = 1,     // 已领取
    CJYeeRedPacketStatusNull = 2,    // 领完了
    CJYeeRedPacketStatusDue  = 3,    // 过期了
};

NS_ASSUME_NONNULL_BEGIN

@interface CJYeePayRedPacketAtachment : NSObject <CJCustomAttachmentCoding, CJCustomAttachmentInfo>

@property (nonatomic, copy) NSString *redPacketId;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *money;        // 金额

@property (nonatomic,nonatomic) NSInteger count;        // 红包个数

@property (nonatomic,nonatomic) NSInteger  status;    // 状态 0 正常 1灰色

@end

NS_ASSUME_NONNULL_END
