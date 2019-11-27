#import "NimSdkUtilPlugin.h"
#import <NIMKit.h>
#import <CJBase/CJBase.h>
#import <Foundation/Foundation.h>

NSDictionary *JsonStringDecode(NSString *jsonString)
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        return nil;
    }
    return dic;
}


@implementation NimSdkUtilPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"nim_sdk_util"
            binaryMessenger:[registrar messenger]];
  NimSdkUtilPlugin* instance = [[NimSdkUtilPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result
{
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else {
      SEL sel = NSSelectorFromString(call.method);
      if([NimSdkUtilPlugin respondsToSelector:sel]) {
          NSArray *params = call.arguments;
          NSMutableArray *p = params?params.mutableCopy : @[].mutableCopy;
          [p addObject:result];
          [NimSdkUtilPlugin performSelector:sel
                                 withObject:p
                                 afterDelay:0];
      }else {
          result(FlutterMethodNotImplemented);
      }
  }
}

+ (void)registerSDK
{
#ifdef DEBUG
    static NSString *ApnsCername = @"cajiandev";
#else
    static NSString *ApnsCername = @"cajiandis";
#endif
    NSString *appKey        = @"0cc61ff22dda75b52c0e922e59d1077e";
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername      = ApnsCername;
    option.pkCername        = @"DEMO_PUSH_KIT";
    [[NIMSDK sharedSDK] registerWithOption:option];
}

// 登录云信sdk
+ (void)doLogin:(NSArray *)params
{
    NSString *accid = params.firstObject;
    NSString *token = params[1];
    
    FlutterResult result = params.lastObject;
    [[NIMSDK sharedSDK].loginManager login:accid
                                     token:token
                                completion:^(NSError * _Nullable error)
     {
         if(!error) {
             ZZLog(@"云信登录成功");
             result(@(YES));
         }else {
             ZZLog(@"%@", error);
             result(@(NO));
         }
     }];
}

// 自动登录
+ (void)autoLogin:(NSArray *)params
{
    [[NIMSDK sharedSDK].loginManager autoLogin:params.firstObject
                                         token:params[1]];
}

+ (void)autoLogin:(NSString *)accid
            token:(NSString *)token
{
    [[NIMSDK sharedSDK].loginManager autoLogin:accid
                                         token:token];
}

// 登出
+ (void)logout
{
    [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"登出失败！"];
        }else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"flutter.accid"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"flutter.token"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didLogout"
                                                                object:self];
        }
    }];
}

// 返回用户信息
+ (void)userInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *accid = [NIMSDK sharedSDK].loginManager.currentAccount;
    if([params.firstObject isKindOfClass:NSString.class]) {
        accid = params.firstObject;
    }
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:accid];
    NIMUserInfo *userInfo = user.userInfo;
    NSDictionary *cjExt = JsonStringDecode(userInfo.ext);
    result(@{
             @"showName": userInfo.nickName ?:[NSNull null],
             @"avatarUrlString": userInfo.avatarUrl ?:[NSNull null],
             @"thumbAvatarUrl" : userInfo.thumbAvatarUrl ?:[NSNull null],
             @"sign" : userInfo.sign ?:[NSNull null],
             @"gender": @(userInfo.gender),
             @"email": userInfo.email ?:[NSNull null],
             @"birth": userInfo.birth ?:[NSNull null],
             @"mobile": userInfo.mobile ?:[NSNull null],
             @"cajianNo": cjExt[@"cajian_id"]?:[NSNull null],
             @"alias": user.alias?:[NSNull null],
             @"userId": user.userId?:[NSNull null]
             });
}

// 返回群信息
+ (void)teamInfo:(NSArray *)params
{
    NSString *teamId = params.firstObject;
    FlutterResult result = params.lastObject;
    NIMKitInfo *info = [[NIMKit sharedKit] infoByTeam:teamId
                                               option:nil];
    
    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:teamId];
    
    result(@{
        @"showName": info.showName?:[NSNull null],
        @"avatarUrlString": info.avatarUrlString?: [NSNull null],
         @"avatarImage": [FlutterStandardTypedData typedDataWithBytes:UIImagePNGRepresentation(info.avatarImage)],
        @"teamId": team.teamId?:[NSNull null],
        @"teamName": team.teamName?:[NSNull null],
        @"thumbAvatarUrl": team.thumbAvatarUrl?:[NSNull null],
        @"type": @(team.type),
        @"owner": team.owner?:[NSNull null],
        @"intro": team.intro?:[NSNull null],
        @"announcement": team.announcement?:[NSNull null],
        @"memberNumber": @(team.memberNumber),
        @"level": @(team.level),
        @"createTime": @(team.createTime),
        @"joinMode": @(team.joinMode),
        @"inviteMode": @(team.inviteMode),
        @"beInviteMode": @(team.beInviteMode),
        @"updateInfoMode": @(team.updateInfoMode),
        @"updateClientCustomMode": @(team.updateClientCustomMode),
        @"serverCustomInfo": team.serverCustomInfo?:[NSNull null],
        @"clientCustomInfo": team.clientCustomInfo?:[NSNull null],
        @"notifyStateForNewMsg": @(team.notifyStateForNewMsg),
    });
}

// 获取好友列表
+ (void)friends:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSMutableArray *contacts = @[].mutableCopy;
    for (NIMUser *user in [NIMSDK sharedSDK].userManager.myFriends) {
        NIMKitInfo *info           = [[NIMKit sharedKit] infoByUser:user.userId option:nil];
        NSDictionary *contact = @{
                                  @"infoId": info.infoId?:[NSNull null],
                                  @"showName": info.showName?:[NSNull null],
                                  @"avatarUrlString": info.avatarUrlString ?:[NSNull null]
                                  };
        [contacts addObject:contact];
    }
    result(contacts);
}

// 群聊列表
+ (void)allMyTeams:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSMutableArray *teamInfos = @[].mutableCopy;
    for (NIMTeam *team in [NIMSDK sharedSDK].teamManager.allMyTeams) {
        [teamInfos addObject:@{
            @"teamId": team.teamId?:[NSNull null],
            @"teamName": team.teamName?:[NSNull null],
            @"teamAvatar": team.avatarUrl?:[NSNull null]
        }];
    }
    result(teamInfos);
}

// 群成员信息
+ (void)teamMemberInfos:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSMutableArray *teamMemberInfos = @[].mutableCopy;
    NSString *teamId = params.firstObject;
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:teamId
                                          completion:^(NSError * _Nullable error, NSArray<NIMTeamMember *> * _Nullable members)
    {
        for (NIMTeamMember *member in members) {
            [teamMemberInfos addObject:@{
                @"teamId": member.teamId?:[NSNull null],
                @"userId": member.userId?:[NSNull null],
                @"invitor": member.invitor?:[NSNull null],
                @"inviterAccid": member.inviterAccid?:[NSNull null],
                @"type": @(member.type),
                @"nickname": member.nickname?:[NSNull null],
                @"isMuted": @(member.isMuted),
                @"createTime": @(member.createTime),
                @"customInfo": member.customInfo?:[NSNull null]
            }];
            
            if(member == members.lastObject) {
                result(teamMemberInfos);
                return;
            }
        }
        // 没有成员或者error了
        result(@[]);
    }];
}

// 获取单个群成员信息
+ (void)teamMemberInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *teamId = params.firstObject;
    NSString *userId = [params tn_objectAtIndex:1];
    NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:userId inTeam:teamId];
    result(@{
        @"teamId": member.teamId?:[NSNull null],
        @"userId": member.userId?:[NSNull null],
        @"invitor": member.invitor?:[NSNull null],
        @"inviterAccid": member.inviterAccid?:[NSNull null],
        @"type": @(member.type),
        @"nickname": member.nickname?:[NSNull null],
        @"isMuted": @(member.isMuted),
        @"createTime": @(member.createTime),
        @"customInfo": member.customInfo?:[NSNull null]
    });
}

// 获取会话置顶状态
+ (void)isStickedOnTop:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *sessionId = params.firstObject;
    NSNumber *type = params[1];
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:[NIMSession session:sessionId type:type.integerValue]];
    BOOL isTop = [self recentSessionIsMark:recent
                                      type:1];
    
    result(@(isTop));
}

// 获取会话是否开启消息提醒
+ (void)isNotifyForNewMsg:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *sessionId = params.firstObject;
    NSNumber *type = [params tn_objectAtIndex:1];
    
    BOOL notifyForNewMsg = NO;
    if(type.integerValue == 0) {
        notifyForNewMsg = [[NIMSDK sharedSDK].userManager notifyForNewMsg:sessionId];
    }else {
        NIMTeamNotifyState state = [[NIMSDK sharedSDK].teamManager notifyStateForNewMsg:sessionId];
        notifyForNewMsg = state == NIMTeamNotifyStateAll;
    }
    
    result(@(notifyForNewMsg));
}

// 清空聊天记录
+ (void)clearChatHistory:(NSArray *)params
{
    NSString *sessionId = params.firstObject;
    NSNumber *type = params[1];
    NIMSession *session = [NIMSession session:sessionId
                                         type:type.integerValue];
    
    [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:session
                                                                option:nil];
}

// 置顶聊天
+ (void)stickSessinOnTop:(NSArray *)params
{
    NSString *sessionId = params.firstObject;
    NSNumber *type = params[1];
    BOOL isTop = [params[2] boolValue];
    
    NIMSession *session = [NIMSession session:sessionId
                                         type:type.integerValue];
    if(isTop) {
        [self addRecentSessionMark:session type:1];
    }else {
        [self removeRecentSessionMark:session type:1];
    }
}

// 开关消息通知
+ (void)changeNotifyStatus:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *sessionId = params.firstObject;
    NSNumber *type = params[1];
    BOOL needMsgNotify = [params[2] boolValue];
    
    void(^errorBlock)(NSError *) = ^(NSError * _Nullable error){
        if(error) {
            [UIViewController showError:@"修改失败！"];
            result(@(NO));
        }else {
            result(@(YES));
        }
    };
    
    if(type.integerValue == 0) {
        [[NIMSDK sharedSDK].userManager updateNotifyState:needMsgNotify
                                                  forUser:sessionId
                                               completion:errorBlock];
    }else {
        NIMTeamNotifyState state = needMsgNotify? NIMTeamNotifyStateAll : NIMTeamNotifyStateNone;
        [[NIMSDK sharedSDK].teamManager updateNotifyState:state
                                                   inTeam:sessionId
                                               completion:errorBlock];
    }
    
}


/// 退出群聊
/// @param params 群id
+ (void)quitTeam:(NSArray *)params
{
    NSString *teamId = params.firstObject;
    FlutterResult result = params.lastObject;
    [[NIMSDK sharedSDK].teamManager quitTeam:teamId
                                  completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"退出群聊失败，请重试"];
            result(@(NO));
        }else {
            result(@(YES));
        }
    }];
}


/// 解散群聊
/// @param params 群id
+ (void)dismissTeam:(NSArray *)params
{
    NSString *teamId = params.firstObject;
    FlutterResult result = params.lastObject;
    [[NIMSDK sharedSDK].teamManager dismissTeam:teamId
                                     completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"解散群聊失败，请重试"];
            result(@(NO));
        }else {
            result(@(YES));
        }
    }];
}

#pragma mark ----- private --------
+ (BOOL)recentSessionIsMark:(NIMRecentSession *)recent
                       type:(NSInteger)type
{
    NSDictionary *localExt = recent.localExt;
    NSString *key = [self keyForMarkType:type];
    return [localExt[key] boolValue] == YES;
}

/*
 // 最近会话本地扩展标记类型
 typedef NS_ENUM(NSInteger, NTESRecentSessionMarkType){
     // @ 标记
     NTESRecentSessionMarkTypeAt,
     // 置顶标记
     NTESRecentSessionMarkTypeTop,
 };
 */
+ (NSString *)keyForMarkType:(NSInteger)type
{
    static NSDictionary *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @{
                 @(0) : @"NTESRecentSessionAtMark",
                 @(1) : @"NTESRecentSessionTopMark"
                 };
    });
    return [keys objectForKey:@(type)];
}


+ (void)addRecentSessionMark:(NIMSession *)session
                        type:(NSInteger)type
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent)
    {
        NSDictionary *localExt = recent.localExt?:@{};
        NSMutableDictionary *dict = [localExt mutableCopy];
        NSString *key = [self keyForMarkType:type];
        [dict setObject:@(YES) forKey:key];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:dict recentSession:recent];
    }


}

+ (void)removeRecentSessionMark:(NIMSession *)session
                           type:(NSInteger)type
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent) {
        NSMutableDictionary *localExt = [recent.localExt mutableCopy];
        NSString *key = [self keyForMarkType:type];
        [localExt removeObjectForKey:key];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:localExt recentSession:recent];
    }
}


@end
