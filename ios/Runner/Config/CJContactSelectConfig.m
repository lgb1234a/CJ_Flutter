//
//  CJContactSelectConfig.m
//  Runner
//
//  Created by chenyn on 2019/9/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJContactSelectConfig.h"
#import "NIMGroupedData.h"
#import "NIMGroupedUsrInfo.h"

@implementation CJContactFriendSelectConfig

- (BOOL)isMutiSelected{
    return self.needMutiSelected;
}

- (NSString *)title
{
    if(_title) {
        return _title;
    }
    return @"选择联系人";
}


- (NSInteger)maxSelectedNum{
    if (self.needMutiSelected) {
        return self.maxSelectMemberCount? self.maxSelectMemberCount : NSIntegerMax;
    }else{
        return 1;
    }
}

- (NSString *)selectedOverFlowTip
{
    return @"选择超限";
}

- (void)getContactData:(NIMContactDataProviderHandler)handler {
    NIMGroupedData *groupedData = [[NIMGroupedData alloc] init];
    NSMutableArray *myFriendArray = @[].mutableCopy;
    NSMutableArray *data = [NIMSDK sharedSDK].userManager.myFriends.mutableCopy;
    NSArray *robot_uids = @[].mutableCopy;
    NSMutableArray *members = @[].mutableCopy;
    
    for (NIMUser *user in data) {
        [myFriendArray addObject:user.userId];
    }
    NSArray *friend_uids = [self filterData:myFriendArray];
    for (NSString *uid in friend_uids) {
        NIMGroupUser *user = [[NIMGroupUser alloc] initWithUserId:uid];
        [members addObject:user];
    }
    groupedData.members = members;
    if (members) {
        [members removeAllObjects];
    }
    if (self.enableRobot) {
        NSMutableArray *robotsArr = @[].mutableCopy;
        NSMutableArray *robot_data = [NIMSDK sharedSDK].robotManager.allRobots.mutableCopy;
        for (NIMRobot *robot in robot_data) {
            [robotsArr addObject:robot.userId];
        }
        robot_uids = [self filterData:robotsArr];
        for (NSString *uid in robot_uids) {
            NIMGroupUser *user = [[NIMGroupUser alloc] initWithUserId:uid];
            [members addObject:user];
        }
        groupedData.specialMembers = members;
    }
    if (handler) {
        handler(groupedData.contentDic, groupedData.sectionTitles);
    }
}

- (NSArray *)filterData:(NSMutableArray *)data{
    if (data) {
        if ([self respondsToSelector:@selector(filterIds)]) {
            NSArray *ids = [self filterIds];
            [data removeObjectsInArray:ids];
        }
        return data;
    }
    return nil;
}

- (NIMKitInfo *)getInfoById:(NSString *)selectedId {
    NIMKitInfo *info = nil;
    info = [[NIMKit sharedKit] infoByUser:selectedId option:nil];
    return info;
}

@end

@implementation CJContactTeamMemberSelectConfig : NSObject

- (NSInteger)maxSelectedNum{
    if (self.needMutiSelected) {
        return self.maxSelectMemberCount? self.maxSelectMemberCount : NSIntegerMax;
    }else{
        return 1;
    }
}

- (NSString *)title{
    if(_title) {
        return _title;
    }
    return @"选择联系人";
}


- (NSString *)selectedOverFlowTip{
    return @"选择超限";
}

- (void)getContactData:(NIMContactDataProviderHandler)handler {
    NIMGroupedData *groupedData = [[NIMGroupedData alloc] init];
    NSString *teamID = self.teamId;
    __block NSMutableArray *membersArr = @[].mutableCopy;
    CJ_WEAK_SELF(weakSelf);
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:teamID completion:^(NSError * _Nullable error, NSArray<NIMTeamMember *> * _Nullable members) {
        if (!error) {
            NSMutableArray *teamMember_data = @[].mutableCopy;
            NSArray *robot_uids = @[].mutableCopy;
            for (NIMTeamMember *member in members) {
                [teamMember_data addObject:member.userId];
            }
            NSArray *member_uids = [weakSelf filterData:teamMember_data];
            for (NSString *uid in member_uids) {
                NIMGroupTeamMember *user = [[NIMGroupTeamMember alloc] initWithUserId:uid teamId:teamID];
                [membersArr addObject:user];
            }
            groupedData.members = membersArr;
            if (membersArr) {
                [membersArr removeAllObjects];
            }
            if (weakSelf.enableRobot) {
                NSMutableArray *robotsArray = @[].mutableCopy;
                NSMutableArray *robot_data = [NIMSDK sharedSDK].robotManager.allRobots.mutableCopy;
                for (NIMRobot *robot in robot_data) {
                    [robotsArray addObject:robot.userId];
                }
                robot_uids = [weakSelf filterData:robotsArray];
                for (NSString *uid in robot_uids) {
                    NIMGroupUser *user = [[NIMGroupUser alloc] initWithUserId:uid];
                    [membersArr addObject:user];
                }
                groupedData.specialMembers = membersArr;
            }
            if (handler) {
                handler(groupedData.contentDic, groupedData.sectionTitles);
            }
        }
    }];
    
}

- (NSArray *)filterData:(NSMutableArray *)data{
    if (data) {
        if ([self respondsToSelector:@selector(filterIds)]) {
            NSArray *ids = [self filterIds];
            [data removeObjectsInArray:ids];
        }
        return data;
    }
    return nil;
}

- (NIMKitInfo *)getInfoById:(NSString *)selectedId {
    NIMKitInfo *info = nil;
    info = [[NIMKit sharedKit] infoByUser:selectedId option:nil];
    return info;
}

@end
