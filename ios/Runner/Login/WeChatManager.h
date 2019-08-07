//
//  WetChatManager.h
//  CaJian
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeChatManager : NSObject

// 绑定微信
+ (void)wxBindCode:(NSString *)code;

+ (void)sendLoginAuth:(NSString*)accessToken
               result:(void (^)(BaseModel *model))result;

@end
