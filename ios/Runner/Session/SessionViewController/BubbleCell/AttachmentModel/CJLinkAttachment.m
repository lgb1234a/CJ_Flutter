//
//  CJLinkAttachment.m
//  Runner
//
//  Created by chenyn on 2019/12/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJLinkAttachment.h"

@interface CJLinkAttachment ()

@property (nonatomic, assign) CJCustomMessageType type;

@end

@implementation CJLinkAttachment

- (NSString *)encodeAttachment {
    NSDictionary *dictContent = @{
                                  @"webpageTitle"    :  self.title ? : @"",
                                  @"webpageContent"  :  self.content ? : @"",
                                  @"webpageUrl"      :  self.weburl ? : @"",
                                  @"webpageImageData":  self.imageData ? : @"",
                                  @"webpageAppName"  :  self.appname ? : @"",
                                  @"webpageAppIcon"  :  self.appicon ? : @"",
                                  @"webpageExtention":  self.extention ? : @"",
                                 };
    
    
    NSDictionary *dict = @{@"type": @(CustomMessageTypeWebPage), @"data": dictContent};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}


- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width {
    return CGSizeMake(222, 103);
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

- (NSString *)cellContent:(NIMMessage *)message{
   return @"CJLinkContentView";
}

- (BOOL)canBeForwarded
{
    return YES;
}

- (BOOL)canBeRevoked
{
    return YES;
}

- (instancetype)initWithPrepareData:(NSDictionary *)data
                               type:(CJCustomMessageType)type
{
    self = [super init];
    if (self) {
        self.title = data[@"webpageTitle"];
        self.content  = data[@"webpageContent"];
        self.weburl = data[@"webpageUrl"];
        self.imageData = data[@"webpageImageData"];
        self.appname = data[@"webpageAppName"];
        self.appicon = data[@"webpageAppIcon"];
        self.extention = data[@"webpageExtention"];
    }
    return self;
}

- (BOOL)isValid { 
    return YES;
}

- (NSString *)newMsgAcronym { 
    return @"[分享链接]";
}

- (BOOL)shouldShowNickName { 
    return YES;
}

- (BOOL)shouldShowAvatar {
    return YES;
}

- (void)handleTapCellEvent:(NIMKitEvent *)event
                 onSession:(NIMSessionViewController *)sessionVC
{
    /// 唤起第三方浏览器or内部落地页
    // 打开网页
    if(self.type == CustomMessageTypeWebPage) {
        NSURL *openURL = [NSURL URLWithString:@"cj80278eefe3e24db2://type=BJHL,id=123456"];
        [[UIApplication sharedApplication] openURL:openURL];
    }else {
        [FlutterBoostPlugin open:@"web_view"
                       urlParams:@{@"url": self.weburl}
                            exts:@{@"animated": @(YES)}
                  onPageFinished:^(NSDictionary *d) {
            
        } completion:^(BOOL c) {
            
        }];
    }
}


@end
