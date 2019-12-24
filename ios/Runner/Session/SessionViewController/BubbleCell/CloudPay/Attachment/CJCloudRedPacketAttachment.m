//
//  CJCloudRedPacketAttachment.m
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJCloudRedPacketAttachment.h"
#import "JRMFHeader.h"
#import "NTESSessionUtil.h"
#import "CJCloudRedPacketTipAttachment.h"

@interface CJCloudRedPacketAttachment () <MFManagerDelegate>

@property (nonatomic, weak) NIMSession *session;

@end

@implementation CJCloudRedPacketAttachment
{
    /// 红包发送人
    NSString *_redpacketFrom;
    /// 红包消息
    NIMMessage *_redpacketMsg;
}

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
    
    
    NSDictionary *dict = @{@"type": @(CustomMessageTypeCloudRedPacket), @"data": dictContent};
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
    return @"CJCloudRedPacketContentView";
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
    return @"[云红包]";
}

// MARK: 之前的NTESSessionMsgConverter拆分出来，由各自attachment model类维护
// 这里只是写个例子，按业务需要去实现
- (NIMMessage *)msgFromAttachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = self;
    message.messageObject             = customObject;
    message.apnsContent = @"发来了一个云红包";
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    message.setting            = setting;
    
    return message;
}

// 点击红包气泡
- (void)handleTapCellEvent:(NIMKitEvent *)event
                 onSession:(NIMSessionViewController *)sessionVC
{
    self.session = sessionVC.session;
    _redpacketFrom = event.messageModel.message.from;
    _redpacketMsg = event.messageModel.message;
    
    NIMCustomObject *object = (NIMCustomObject *)event.messageModel.message.messageObject;
    CJCloudRedPacketAttachment *attachment = (CJCloudRedPacketAttachment *)object.attachment;
    
    MFPacket *jrmf = [[MFPacket alloc] init];
    jrmf.delegate = self;
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSString *nickName = [NTESSessionUtil showNick:me inSession:self.session];
    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;
    BOOL isGroup = self.session.sessionType == NIMSessionTypeTeam;
    
    [jrmf doActionPresentOpenViewController:cj_rootNavigationController()
                                 thirdToken:[JRMFSington GetPacketSington].MFThirdToken
                               withUserName:nickName
                                   userHead:headUrl
                                     userID:me
                                 envelopeID:attachment.redPacketId
                                    isGroup:isGroup];
}

- (void)doMFActionGetPacketStatus:(MFPacketStatusType)type
{
    NIMMessage *msg = _redpacketMsg;
    // 状态已经改变过 不用处理
    if (self.status != CloudRedPacketStatusNormal) {
        return;
    }
    else
    {
        // 红包已领取 红包领完了 红包失效 改变下状态
        if (type == MFPacketIsGet || type == MFPacketIsNull || type == MFPacketIsDue) {
            self.status = type;
            
            // 回写下缓存数据里
            id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
            [manager updateMessage:msg forSession:self.session completion: ^(NSError * __nullable error)
             {
                 // 数据回写失败
                 if (error != nil) {
                     self.status = CloudRedPacketStatusNormal;
                 }
                // 这里最好还要刷新下红包视图 否则返回去以后 不能同步
                [[NSNotificationCenter defaultCenter] postNotificationName:CJUpdateMessageNotification
                                                                    object:msg];
             }];
        }
    }
    
}

- (void)doMFActionOpenPacketSuccessWith:(NSInteger)hasLeft total:(NSInteger)total totalMoney:(NSString *)totalMoney grabMoney:(NSString *)grabMoney
{
    CJCloudRedPacketTipAttachment *tip = [CJCloudRedPacketTipAttachment new];
    tip.isGetDone = !hasLeft;
    tip.openPacketId = [[NIMSDK sharedSDK].loginManager currentAccount];
    tip.packetId = self.redPacketId;
    tip.sendPacketId = _redpacketFrom;
    
    [[NIMSDK sharedSDK].chatManager sendMessage:[tip msgFromAttachment]
                                      toSession:self.session
                                          error:nil];
    
    
    if (self.money == nil) {
        self.money = @"";
    }
    self.status = MFPacketIsGet;
    // 回写下缓存数据里
    id<NIMConversationManager> manager = [[NIMSDK sharedSDK] conversationManager];
    [manager updateMessage:_redpacketMsg
                forSession:self.session
                completion: ^(NSError * __nullable error)
     {
         // 数据回写失败
         if (error != nil) {
             self.status = CloudRedPacketStatusNormal;
         }
         // 这里最好还要刷新下红包视图 否则返回去以后 不能同步
         [[NSNotificationCenter defaultCenter] postNotificationName:CJUpdateMessageNotification
                                                             object:self->_redpacketMsg];
     }];
}

@end
