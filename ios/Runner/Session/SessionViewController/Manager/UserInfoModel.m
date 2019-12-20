//
//  UserInfoModel.m
//  IMFrameworkDemo
//
//  Created by Criss on 2017/12/14.
//  Copyright © 2017年 JYang. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

+ (void)getCustomerInfoWith:(NSString *)cId complate:(GetUserInfo)block { 
    ZZLog(@"接受到id-%@",cId);
    if (block) {
        
        NSString *accid = cId;
        NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:accid];
        NSString* avatarURL = user.userInfo.avatarUrl;
        if (avatarURL != nil && [avatarURL isEqualToString:@""] == NO ) {
            block(avatarURL,nil);
        }
    }
}

@end
