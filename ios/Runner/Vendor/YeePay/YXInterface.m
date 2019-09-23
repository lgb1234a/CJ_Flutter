//
//  YXInterface.m
//  CaJian
//
//  Created by chenyn on 2019/8/19.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YXInterface.h"


ZZUserInfoModel *userInfo(NSString *uid)
{
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid
                                               option:nil];
    ZZUserInfoModel *userInfo = [ZZUserInfoModel new];
    userInfo.nickName = info.showName;
    userInfo.avatarUrl = info.avatarUrlString;
    userInfo.avatarImage = info.avatarImage;
    return userInfo;
}
@implementation YXInterface

@end
