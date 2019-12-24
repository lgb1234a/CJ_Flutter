//
//  CJYeePayRedPacketTipAttachment.m
//  Runner
//
//  Created by chenyn on 2019/9/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJYeePayRedPacketTipAttachment.h"
#import <NIMKitInfoFetchOption.h>
#import "JRMFHeader.h"

@interface CJYeePayRedPacketTipAttachment()

@property (nonatomic,weak) NIMMessage *message;

@end

@implementation CJYeePayRedPacketTipAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dictContent = @{
                                  @"sendPacketId" :  self.sendPacketId ? : @"",
                                  @"openPacketId" :  self.openPacketId ? : @"",
                                  @"redPacketId"  :  self.packetId ? : @"",
                                  @"isGetDone" :  self.isGetDone ? : @"",
                                  };
    
    
    NSDictionary *dict = @{@"type": @(CustomMessageTypeYeeRedPacketTip), @"data": dictContent};
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
    NSString * showContent;
    NSString * currentUserId = [[NIMSDK sharedSDK].loginManager currentAccount];
    // 领取别人的红包
    NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
    option.message = self.message;
    
    if ([currentUserId isEqualToString:self.sendPacketId] && [currentUserId isEqualToString:self.openPacketId])
    {
        if ([self.isGetDone boolValue])
        {
            showContent = @"你领取了自己的红包，你的红包已被领完";
        }
        else
        {
            showContent = @"你领取了自己的红包";
        }
    }
    else if ([currentUserId isEqualToString:self.openPacketId])
    {
        NIMKitInfo *sendUserInfo = [[NIMKit sharedKit] infoByUser:self.sendPacketId option:option];
        NSString *name = sendUserInfo.showName;
        showContent = [NSString stringWithFormat:@"你领取了%@的红包", name];
    }
    
    // 他人领取你的红包
    else if ([currentUserId isEqualToString:self.sendPacketId])
    {
        NIMKitInfo * openUserInfo = [[NIMKit sharedKit] infoByUser:self.openPacketId option:option];
        NSString * name = openUserInfo.showName;
        
        if ([self.isGetDone boolValue])
        {
            showContent = [NSString stringWithFormat:@"%@领取了你的红包，你的红包已被领完", name];
        }
        else
        {
            showContent = [NSString stringWithFormat:@"%@领取了你的红包", name];
        }
    }
    
    return showContent.length == 0 ? @"" : [NSString stringWithFormat:@"  %@",showContent];
}

// 气泡内边距
- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    return UIEdgeInsetsZero;
}

// model类绑定
- (NSString *)cellContent:(NIMMessage *)message
{
    return @"CJYeeRedPacketTipContentView";
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

- (void)handleTapCellEvent:(NIMKitEvent *)event
                 onSession:(NIMSessionViewController *)sessionVC
{
    /// 点击了红包提示消息,跳转红包详情
    MFPacket *jrmf = [[MFPacket alloc] init];
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    [jrmf doActionPresentPacketDetailInViewWithUserID:me
                                             packetID:_packetId
                                           thirdToken:[JRMFSington GetPacketSington].MFThirdToken];
}

@end
