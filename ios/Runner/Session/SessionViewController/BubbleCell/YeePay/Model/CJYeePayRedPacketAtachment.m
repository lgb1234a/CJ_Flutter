//
//  CJYeePayRedPacketAtachment.m
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJYeePayRedPacketAtachment.h"

@implementation CJYeePayRedPacketAtachment

- (NSString *)encodeAttachment
{
    NSDictionary *dictContent = @{
                                  @"title"            :  self.title ? : @"",
                                  @"content"          :  self.content ? : @"",
                                  @"redPacketId"      :  self.redPacketId ? : @"",
                                  @"redPacketMoney"   :  self.money ? : @"",
                                  @"redPacketCount"   :  @(self.count) ? : @"",
                                  @"redPacketStatus"  :  @(self.status) ? : @"",
                                  };
    
    
    NSDictionary *dict = @{@"type": @(CustomMessageTypeYeeRedPacket), @"data": dictContent};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}

// 气泡大小
- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width
{
    return CGSizeMake(220, 85);
}

// 气泡内边距
- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    CGFloat bubblePaddingForImage    = 3.f;
    CGFloat bubbleArrowWidthForImage = 5.f;
    if (message.isOutgoingMsg) {
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage);
    }else{
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage, bubblePaddingForImage,bubblePaddingForImage);
    }
}

// model类绑定
- (NSString *)cellContent:(NIMMessage *)message
{
    return @"CJYeeRedPacketContentView";
}

- (BOOL)canBeForwarded
{
    return NO;
}

- (BOOL)canBeRevoked
{
    return NO;
}

#pragma mark - CJCustomAttachmentCoding
- (BOOL)isValid
{
    return YES;
}

- (instancetype)initWithPrepareData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.title = [data objectForKey:@"title"];
        self.content = [data objectForKey:@"content"];
        self.redPacketId = [data objectForKey:@"redPacketId"];
        self.money = [data objectForKey:@"redPacketMoney"];
        self.count = [[data objectForKey:@"redPacketCount"] integerValue];
        self.status = [[data objectForKey:@"redPacketStatus"] integerValue];
    }
    return self;
}

- (BOOL)shouldShowNickName
{
    return YES;
}


- (BOOL)shouldShowAvatar
{
    return YES;
}

- (NSString *)newMsgAcronym
{
    return @"[易红包]";
}

// MARK: 之前的NTESSessionMsgConverter拆分出来，由各自attachment model类维护
// 这里只是写个例子，按业务需要去实现
- (NIMMessage *)msgFromAttachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = self;
    message.messageObject             = customObject;
    message.apnsContent = @"发来了一个易红包";
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    message.setting            = setting;
    
    return message;
}

// 点击红包气泡
- (void)handleTapCellEvent:(NIMKitEvent *)event
                 onSession:(NIMSessionViewController *)sessionVC
{
    
}

@end
