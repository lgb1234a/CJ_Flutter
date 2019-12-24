//
//  CJLinkAttachment.h
//  Runner
//
//  Created by chenyn on 2019/12/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJCustomAttachmentDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJLinkAttachment : NSObject <CJCustomAttachment, CJCustomAttachmentInfo>

// 标题
@property (nonatomic, copy) NSString *title;

// 内容
@property (nonatomic, copy) NSString *content;

// 点击链接
@property (nonatomic, copy) NSString *weburl;

// 分享大图片数据
@property (nonatomic, copy) NSString *imageData;

// 应用名
@property (nonatomic, copy) NSString *appname;

// 应用icon链接
@property (nonatomic, copy) NSString *appicon;

// 扩展数据
@property (nonatomic, copy) NSString *extention;

@end

NS_ASSUME_NONNULL_END
