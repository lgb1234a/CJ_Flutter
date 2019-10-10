//
//  YXInterface.h
//  CaJian
//
//  Created by chenyn on 2019/8/19.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YouXiPayUISDK/YouXiPayUISDK.h>

extern ZZUserInfoModel *userInfo(NSString * uid);
extern ZZUserInfoModel *teamOwnerInfo(NSString *teamId);

NS_ASSUME_NONNULL_BEGIN

@interface YXInterface : NSObject

@end

NS_ASSUME_NONNULL_END
