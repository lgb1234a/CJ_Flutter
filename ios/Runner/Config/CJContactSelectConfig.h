//
//  CJContactSelectConfig.h
//  Runner
//
//  Created by chenyn on 2019/9/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMContactSelectConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  内置配置-选择好友
 */
@interface CJContactFriendSelectConfig : NSObject<NIMContactSelectConfig>

@property (nonatomic, copy) NSString *title;

@property (nonatomic,assign) BOOL needMutiSelected;

@property (nonatomic,assign) NSInteger maxSelectMemberCount;

@property (nonatomic,copy) NSArray *alreadySelectedMemberId;

@property (nonatomic,copy) NSArray *filterIds;

@property (nonatomic,assign) BOOL showSelectDetail;

@property (nonatomic,assign) BOOL enableRobot;

@end

/**
 *  内置配置-选择群成员
 */
@interface CJContactTeamMemberSelectConfig : NSObject<NIMContactSelectConfig>

@property (nonatomic, copy) NSString *title;

@property (nonatomic,copy) NSString *teamId;

@property (nonatomic,assign) BOOL needMutiSelected;

@property (nonatomic,assign) NSInteger maxSelectMemberCount;

@property (nonatomic,copy) NSArray *alreadySelectedMemberId;

@property (nonatomic,copy) NSArray *filterIds;

@property (nonatomic,assign) BOOL showSelectDetail;

@property (nonatomic,assign) BOOL enableRobot;

@end

NS_ASSUME_NONNULL_END
