//
//  CJMFRedPacketTipAttachment.m
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJMFRedPacketTipAttachment.h"
#import "CJMFRedPacketTipContentView.h"

@interface CJMFRedPacketTipAttachment ()

@property (nonatomic,weak) NIMMessage *message;

@end

@implementation CJMFRedPacketTipAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dictContent = @{
                                  @"sendPacketId" :  self.sendPacketId ? : @"",
                                  @"openPacketId" :  self.openPacketId ? : @"",
                                  @"redPacketId"  :  self.packetId ? : @"",
                                  @"isGetDone" :  self.isGetDone ? : @"",
                                  };
    
    NSDictionary *dict = @{@"type": @(CustomMessageTypeRedPacketTip), @"data": dictContent};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}

// 气泡大小
- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width
{
    self.message = message;
    NSString *formatedMessage = self.formatedMessage;
    CGFloat cellPadding = 11.f;
    CGSize contentSize = CGSizeMake(SCREEN_WIDTH, Notification_Font_Size + 2 * cellPadding);
    return formatedMessage.length == 0 ? CGSizeZero : contentSize;
}

// 消息格式化
- (NSString *)formatedMessage{
    
    return @"易宝版不支持擦肩红包，敬请期待～";
}

// 气泡内边距
- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    return UIEdgeInsetsZero;
}

// model类绑定
- (NSString *)cellContent:(NIMMessage *)message
{
    return NSStringFromClass(CJMFRedPacketTipContentView.class);
}

- (BOOL)canBeForwarded
{
    return NO;
}

- (BOOL)canBeRevoked
{
    return NO;
}

#pragma mark - CJCustomAttachment

- (BOOL)isValid
{
    return YES;
}

- (instancetype)initWithPrepareData:(NSDictionary *)data
                               type:(CJCustomMessageType)type
{
    self = [super init];
    if (self) {
        self.sendPacketId = [data objectForKey:@"sendPacketId"];
        self.packetId = [data objectForKey:@"redPacketId"];
        self.openPacketId = [data objectForKey:@"openPacketId"];
        self.isGetDone = [data objectForKey:@"isGetDone"];
    }
    return self;
}

- (BOOL)shouldShowNickName
{
    return NO;
}


- (BOOL)shouldShowAvatar
{
    return NO;
}

- (NSString *)newMsgAcronym
{
    return self.formatedMessage;
}

// MARK: 之前的NTESSessionMsgConverter拆分出来，由各自attachment model类维护
- (NIMMessage *)msgFromAttachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = self;
    message.messageObject             = customObject;
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.apnsEnabled = NO;
    message.setting            = setting;
    
    return message;
}


@end
