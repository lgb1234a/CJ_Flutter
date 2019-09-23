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

NS_ASSUME_NONNULL_END
