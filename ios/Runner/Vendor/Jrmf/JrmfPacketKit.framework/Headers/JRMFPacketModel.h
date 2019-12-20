//
//  JRMFPacketModel.h
//  JrmfPacketKit
//
//  Created by Criss on 2018/5/25.
//  Copyright © 2018年 JYang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, jrmfSendStatus) {
    kjrmfStatCancel = 0,     // 取消发送，用户行为
    kjrmfStatSucess = 1,     // 红包发送成功
    kjrmfStatUnknow,         // 其他
};

typedef NS_ENUM(NSUInteger, JrmfRedPacketType) {
    RedPacketTypeGroupNormal=0, /**< 群普通 */
    RedPacketTypeGroupPin,      /**< 群拼手气 */
    RedPacketTypeSingle,        /**< 单人红包 */
};

@interface JRMFPacketModel : NSObject

/**< 红包id */
@property (nonatomic,   copy) NSString * packetId;

/**< 红包名称 */
@property (nonatomic,   copy) NSString * packetName;

/**< 红包祝福语 */
@property (nonatomic,   copy) NSString * packetSummary;

/**< 红包类型 */
@property (nonatomic, assign) JrmfRedPacketType  packetType;

/** 红包金额 */
@property (nonatomic , copy) NSString *  numberOfMoney;

/** 红包个数 */
@property (nonatomic , assign) NSInteger   numberOfPackets;


@end
