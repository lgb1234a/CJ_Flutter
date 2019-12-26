//
//  CJLinkAttachment.m
//  Runner
//
//  Created by chenyn on 2019/12/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJLinkAttachment.h"
#import "CJLinkContentView.h"

@interface CJLinkAttachment ()

@property (nonatomic, assign) CJCustomMessageType type;

@end

@implementation CJLinkAttachment

- (NSString *)encodeAttachment {
    NSDictionary *dictContent = @{
                                  @"webpageTitle"    :  self.title ? : @"",
                                  @"webpageContent"  :  self.content ? : @"",
                                  @"webpageUrl"      :  self.webUrl ? : @"",
                                  @"webpageImageData":  self.imageData ? : @"",
                                  @"webpageAppName"  :  self.appName ? : @"",
                                  @"webpageAppIcon"  :  self.appIcon ? : @"",
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
   return NSStringFromClass(CJLinkContentView.class);
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
                               type:(CJCustomMessageType)type
{
    self = [super init];
    if (self) {
        self.title = data[@"webpageTitle"];
        self.content  = data[@"webpageContent"];
        self.webUrl = data[@"webpageUrl"];
        self.imageData = data[@"webpageImageData"];
        self.appName = data[@"webpageAppName"];
        self.appIcon = data[@"webpageAppIcon"];
        self.extention = data[@"webpageExtention"];
        self.type = type;
    }
    return self;
}

- (NSString *)newMsgAcronym { 
    return [NSString stringWithFormat:@"[链接]%@", self.title];
}

- (void)handleTapCellEvent:(NIMKitEvent *)event
                 onSession:(NIMSessionViewController *)sessionVC
{
    /// 唤起第三方浏览器or内部落地页
    // 打开网页
    if(self.type == CustomMessageTypeWebPage) {
        NSURL *openURL = [NSURL URLWithString:@"cj80278eefe3e24db2://type=BJHL,id=123456"];
        [[UIApplication sharedApplication] openURL:openURL];
    }else if(self.type == CustomMessageTypeShareLink){
        [FlutterBoostPlugin open:@"web_view"
                       urlParams:@{@"url": self.webUrl}
                            exts:@{@"animated": @(YES)}
                  onPageFinished:^(NSDictionary *d) {
            
        } completion:^(BOOL c) {
            
        }];
    }else if(self.type == CustomMessageTypeShareApp) {
        /// 应用
        [FlutterBoostPlugin open:@"share_app_detail"
                       urlParams:@{@"imgUrl": cj_not_nil_object(self.imageData),
                                   @"title": cj_not_nil_object(self.title),
                                   @"desc": cj_not_nil_object(self.content),
                                   @"webUrl": cj_not_nil_object(self.webUrl),
                                   @"extention": cj_not_nil_object(self.extention)
                       }
                            exts:@{@"animated": @(YES)}
                  onPageFinished:^(NSDictionary * d)
        {
        } completion:^(BOOL c) {
        }];
    }
}


@end
