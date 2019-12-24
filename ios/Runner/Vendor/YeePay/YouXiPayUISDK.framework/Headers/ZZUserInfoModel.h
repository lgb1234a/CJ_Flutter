//
//  ZZUserInfoModel.h
//  YouXiPayUISDK
//
//  Created by chenyn on 2019/8/19.
//  Copyright © 2019 youxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZUserInfoModel : NSObject

/**
 昵称
 */
@property (nonatomic, copy) NSString *nickName;

/**
 头像地址
 */
@property (nonatomic, copy) NSString *avatarUrl;

/**
 头像占位图
 */
@property (nonatomic, strong) UIImage *avatarImage;

@end

// 指定人红包头像渲染model
@interface ZZAvatarModel : NSObject

@property (nonatomic, copy) NSString *u_id;
@property (nonatomic, copy) NSString *avatarUrl;

/**
 0：未知
 1：男
 2：女
 */
@property (nonatomic, assign) NSInteger gender;

@end

NS_ASSUME_NONNULL_END
