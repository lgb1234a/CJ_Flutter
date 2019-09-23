//
//  CJCustomAttachment.h
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//  attachment基类

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CJCustomMessageType){
    CustomMessageTypeJanKenPon  = 1, //剪子石头布
    CustomMessageTypeSnapchat   = 2, //阅后即焚
    CustomMessageTypeChartlet   = 3, //贴图表情
    CustomMessageTypeWhiteboard = 4, //白板会话
    CustomMessageTypeRedPacket  = 5, //红包消息
    CustomMessageTypeRedPacketTip = 6, //红包提示消息
    
    //自定义的消息类型
    CustomMessageTypePersonalCard = 7, // 个人名片
    CustomMessageTypeWebPage      = 8, // 网页链接
    
    CustomMessageTypeAliPayRedPacket    = 9, //红包消息
    CustomMessageTypeAliPayRedPacketTip = 10, //红包提示消息
    
    //    CustomMessageTypeShareImage   = 11, // 分享图片
    CustomMessageTypeShareApp     = 12, // 分享游戏
    CustomMessageTypeShareLink    = 13, // 分享链接
    CustomMessageTypeShake   = 14, // 分享链接
    CustomMessageTypeRecord   = 16, // 战绩消息
    
    CustomMessageTypeCloudRedPacket = 19, //  云红包
    CustomMessageTypeCloudRedPacketTip = 20, //
    
    CustomMessageTypeSystemNotification = 21, // 擦肩小助手系统通知
    CustomMessageTypeUpdateInfo = 22,  // 擦肩小助手版本更新消息
    CustomMessageTypeRefund = 23,      // 擦肩小助手退款消息
    CustomMessageTypeScreenShotsNotice     = 24, //截屏通知
    //    CustomMessageTypeHelperNotice     = 25, //小助手通知
    CustomMessageTypeArticleNotification  = 26, // 文章推送
    CustomMessageTypeBanRedPacket  = 27, // 禁止领红包
    CustomMessageTypeYeeRedPacket = 28, //易红包
    CustomMessageTypeYeeRedPacketTip = 29,
    CustomMessageTypeYeeTransfer = 30, //易转账
    CustomMessageTypeYeeTransferReceipt = 31,//(接收转账,退回转账)
};

// type -> class name
static NSString *mappingAttachmentForKey(CJCustomMessageType key)
{
    NSDictionary *d = @{
                        @(CustomMessageTypeYeeRedPacket): @"CJYeePayRedPacketAtachment"
                        };
    
    return [d objectForKey:@(key)];
}


@protocol CJCustomAttachmentCoding <NIMCustomAttachment>

@required

/**
 内容是否有效

 @return bool
 */
- (BOOL)isValid;

/**
 拼装attachment model

 @param data
 @param type
 */
- (instancetype)initWithPrepareData:(NSDictionary *)data;

/**
 是否显示头像

 @return bool
 */
- (BOOL)shouldShowNickName;

/**
 是否显示头像

 @return bool
 */
- (BOOL)shouldShowAvatar;


/**
 从attachment model自定义消息

 @return 消息
 */
+ (NIMMessage *)msgFromAttachment;


/**
 新消息缩略语

 @return string
 */
- (NSString *)newMsgAcronym;

@end


@protocol CJCustomAttachmentInfo <NSObject>

@optional

- (NSString *)cellContent:(NIMMessage *)message;

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width;

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message;

- (NSString *)formatedMessage;

- (UIImage *)showCoverImage;

- (BOOL)shouldShowAvatar;

- (void)setShowCoverImage:(UIImage *)image;

- (BOOL)canBeRevoked;

- (BOOL)canBeForwarded;

@end
