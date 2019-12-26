//
//  CJBusinessCardAttachment.m
//  Runner
//
//  Created by chenyn on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJBusinessCardAttachment.h"
#import "CJBusinessCardContentView.h"

@implementation CJBusinessCardAttachment

- (instancetype)initWithShareModel:(CJShareBusinessCardModel *)model
{
    self = [super init];
    if(self) {
        self.accid = model.accid;
        self.nickName = model.nickName;
        self.imageUrl = model.imageUrl;
    }
    return self;
}

- (NSString *)encodeAttachment {
    NSDictionary *dictContent = @{
                                  @"sendCardAccid"    :  self.accid ? : @"",
                                  @"sendCardNickName" :  self.nickName ? : @"",
                                  @"sendCardImageUrl" :  self.imageUrl ? : @""
                                 };
    
    
    NSDictionary *dict = @{@"type": @(CustomMessageTypePersonalCard), @"data": dictContent};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}


- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width {
    return CGSizeMake(230.f, 90.f);
}


- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message {
    CGFloat bubblePaddingForImage    = 3.f;
    CGFloat bubbleArrowWidthForImage = 5.f;
    if (message.isOutgoingMsg) {
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage);
    }else{
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage, bubblePaddingForImage,bubblePaddingForImage);
    }
}

/// 绑定视图view
- (NSString *)cellContent:(NIMMessage *)message{
   return NSStringFromClass(CJBusinessCardContentView.class);
}

- (BOOL)canBeForwarded
{
    return YES;
}

- (BOOL)canBeRevoked
{
    return YES;
}

- (BOOL)isValid
{
    return YES;
}

- (instancetype)initWithPrepareData:(NSDictionary *)data
                               type:(CJCustomMessageType)type {
    self = [super init];
    if(self) {
        self.accid = data[@"sendCardAccid"];
        self.nickName = data[@"sendCardNickName"];
        self.imageUrl = data[@"sendCardImageUrl"];
    }
    return self;
}

- (NSString *)newMsgAcronym {
    return @"[个人名片]";
}

/// 点击事件
- (void)handleTapCellEvent:(NIMKitEvent *)event
                 onSession:(NIMSessionViewController *)sessionVC
{
    if(cj_empty_string(self.accid)) {
        [UIViewController showError:@"该用户id异常！"];
        return;
    }
    [FlutterBoostPlugin open:@"user_info"
                   urlParams:@{@"user_id": self.accid}
                        exts:@{@"animated": @(YES)}
              onPageFinished:^(NSDictionary * _Nonnull d) {
    } completion:^(BOOL c) {
    }];
}

- (NIMMessage *)msgFromAttachment
{
    NIMMessage *message               = [[NIMMessage alloc] init];
    NIMCustomObject *customObject     = [[NIMCustomObject alloc] init];
    customObject.attachment           = self;
    message.messageObject             = customObject;
    
    message.apnsContent = @"推荐了好友名片";
    
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    message.setting            = setting;
    
    return message;
}


@end
