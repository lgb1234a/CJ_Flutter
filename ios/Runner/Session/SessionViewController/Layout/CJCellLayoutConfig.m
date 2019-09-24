//
//  CJCellLayoutConfig.m
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJCellLayoutConfig.h"
#import "CJSessionCustomContentConfig.h"
#import "CJCustomAttachmentDefines.h"

@interface CJCellLayoutConfig ()
@property (nonatomic,strong) CJSessionCustomContentConfig  *sessionCustomconfig;

@end

@implementation CJCellLayoutConfig

- (instancetype)init
{
    if (self = [super init])
    {
        _sessionCustomconfig = [[CJSessionCustomContentConfig alloc] init];
    }
    return self;
}


#pragma mark - NIMCellLayoutConfig
- (CGSize)contentSize:(NIMMessageModel *)model cellWidth:(CGFloat)width{
    
    NIMMessage *message = model.message;
    //检查是不是当前支持的自定义消息类型
    if ([self isSupportedCustomMessage:message])
    {
        return [_sessionCustomconfig contentSize:width message:message];
    }
    
    //如果没有特殊需求，就走默认处理流程
    return [super contentSize:model
                    cellWidth:width];
    
}

- (NSString *)cellContent:(NIMMessageModel *)model{
    
    NIMMessage *message = model.message;
    //检查是不是当前支持的自定义消息类型
    if ([self isSupportedCustomMessage:message]) {
        return [_sessionCustomconfig cellContent:message];
    }
    
    //如果没有特殊需求，就走默认处理流程
    return [super cellContent:model];
}

- (UIEdgeInsets)contentViewInsets:(NIMMessageModel *)model
{
    NIMMessage *message = model.message;
    //检查是不是当前支持的自定义消息类型
    if ([self isSupportedCustomMessage:message]) {
        return [_sessionCustomconfig contentViewInsets:message];
    }
    
    //如果没有特殊需求，就走默认处理流程
    return [super contentViewInsets:model];
}

- (UIEdgeInsets)cellInsets:(NIMMessageModel *)model
{
    NIMMessage *message = model.message;
    
    //检查是不是聊天室消息
    if (message.session.sessionType == NIMSessionTypeChatroom)
    {
        return UIEdgeInsetsZero;
    }
    
    //如果没有特殊需求，就走默认处理流程
    return [super cellInsets:model];
}

- (BOOL)shouldShowAvatar:(NIMMessageModel *)model
{
    if(model.message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject *object = model.message.messageObject;
        id<CJCustomAttachmentCoding> customAttachment = (id<CJCustomAttachmentCoding>)object.attachment;
        return [customAttachment shouldShowAvatar];
    }
    return [super shouldShowAvatar:model];
}

- (BOOL)shouldShowLeft:(NIMMessageModel *)model
{
    return [super shouldShowLeft:model];
}

- (BOOL)shouldShowNickName:(NIMMessageModel *)model
{
    if(model.message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject *object = model.message.messageObject;
        id<CJCustomAttachmentCoding> customAttachment = (id<CJCustomAttachmentCoding>)object.attachment;
        return [customAttachment shouldShowNickName];
    }
    
    return [super shouldShowNickName:model];
}

- (CGPoint)nickNameMargin:(NIMMessageModel *)model
{
    return [super nickNameMargin:model];
}


- (BOOL)isSupportedCustomMessage:(NIMMessage *)message
{
    NIMCustomObject *object = (NIMCustomObject *)message.messageObject;
    NSDictionary *attachmentMap = attachmentMapping();
    return [object isKindOfClass:[NIMCustomObject class]] &&
    [attachmentMap.allValues indexOfObject:NSStringFromClass([object.attachment class])] != NSNotFound;
}

- (NSArray *)customViews:(NIMMessageModel *)model
{
    return [super customViews:model];
}


- (BOOL)disableRetryButton:(NIMMessageModel *)model
{
    if ([model.message.localExt.allKeys containsObject:CJMessageRefusedTag])
    {
        return [[model.message.localExt objectForKey:CJMessageRefusedTag] boolValue];
    }
    return [super disableRetryButton:model];
}

@end
