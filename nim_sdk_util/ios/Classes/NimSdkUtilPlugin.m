#import "NimSdkUtilPlugin.h"
#import <NIMKit.h>
#import <CJBase/CJBase.h>
#import <Foundation/Foundation.h>
#import "NIMMessageMaker.h"

static NSString *nimSDKResultKey = @"flutter_result";
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
          NSDictionary *params = call.arguments;
          NSMutableDictionary *p = params?params.mutableCopy : @{}.mutableCopy;
          [p setObject:result forKey:nimSDKResultKey];
          [NimSdkUtilPlugin performSelector:sel
                                 withObject:p.copy
                                 afterDelay:0];
      }else {
          result(FlutterMethodNotImplemented);
      }
  }
}

+ (void)registerSDK
{
#ifdef DEBUG
    static NSString *ApnsCername = @"cajianflutterdev";
#else
    static NSString *ApnsCername = @"cajianflutterdis";
#endif
    NSString *appKey        = @"0cc61ff22dda75b52c0e922e59d1077e";
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername      = ApnsCername;
    [[NIMSDK sharedSDK] registerWithOption:option];
}

// 登录云信sdk
+ (void)doLogin:(NSDictionary *)params
{
    NSString *accid = params[@"accid"];
    NSString *token = params[@"token"];
    
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].loginManager login:accid
                                     token:token
                                completion:^(NSError * _Nullable error)
     {
         if(!error) {
             ZZLog(@"云信登录成功");
             [self stashLoginInfo:accid token:token];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"didLogin"
                                                                 object:self];
             if(result) result(@(YES));
         }else {
             ZZLog(@"%@", error);
             if(result) result(@(NO));
         }
     }];
}

// 自动登录
+ (void)autoLogin:(NSDictionary *)params
{
    [[NIMSDK sharedSDK].loginManager autoLogin:params[@"accid"]
                                         token:params[@"token"]];
}

+ (void)autoLogin:(NSString *)accid
            token:(NSString *)token
{
    [[NIMSDK sharedSDK].loginManager autoLogin:accid
                                         token:token];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLogin"
                                                        object:self];
}

+ (void)stashLoginInfo:(NSString *)accid
                 token:(NSString *)token
{
    // 加上前缀flutter. 和flutter插件sp保持一致，可以被flutter端读取
    [[NSUserDefaults standardUserDefaults] setObject:accid forKey:@"flutter.accid"];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"flutter.token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 登出
+ (void)logout
{
    [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"登出失败！"];
        }else {
            [self clearLoginInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didLogout"
                                                                object:self];
        }
    }];
}

+ (void)clearLoginInfo
{
    /// 清除登录信息
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"flutter.accid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"flutter.token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 返回用户信息
+ (void)userInfo:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *accid = [NIMSDK sharedSDK].loginManager.currentAccount;
    if(![params[@"userId"] isKindOfClass:NSNull.class]) {
        accid = params[@"userId"];
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
+ (void)teamInfo:(NSDictionary *)params
{
    NSString *teamId = params[@"teamId"];
    FlutterResult result = params[nimSDKResultKey];
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
+ (void)friends:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSMutableArray *contacts = @[].mutableCopy;
    for (NIMUser *user in [NIMSDK sharedSDK].userManager.myFriends) {
        NIMKitInfo *info           = [[NIMKit sharedKit] infoByUser:user.userId option:nil];
        NSDictionary *contact = @{
                                  @"infoId": info.infoId?:[NSNull null],
                                  @"showName": info.showName?:[NSNull null],
                                  @"alias": user.alias?:[NSNull null],
                                  @"ext": user.ext?:[NSNull null],
                                  @"avatarUrlString": info.avatarUrlString ?:[NSNull null]
                                  };
        [contacts addObject:contact];
    }
    result(contacts);
}

// 群聊列表
+ (void)allMyTeams:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
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
+ (void)teamMemberInfos:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSMutableArray *teamMemberInfos = @[].mutableCopy;
    NSString *teamId = params[@"teamId"];
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
+ (void)teamMemberInfo:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *teamId = params[@"teamId"];
    NSString *userId = params[@"userId"];
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
+ (void)isStickedOnTop:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sessionId = params[@"id"];
    NSNumber *type = params[@"type"];
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:[NIMSession session:sessionId type:type.integerValue]];
    BOOL isTop = [self recentSessionIsMark:recent
                                      type:1];
    
    result(@(isTop));
}

// 获取会话是否开启消息提醒
+ (void)isNotifyForNewMsg:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sessionId = params[@"id"];
    NSNumber *type = params[@"type"];
    
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
+ (void)clearChatHistory:(NSDictionary *)params
{
    NSString *sessionId = params[@"id"];
    NSNumber *type = params[@"type"];
    NIMSession *session = [NIMSession session:sessionId
                                         type:type.integerValue];
    
    [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:session
                                                                option:nil];
}

// 置顶聊天
+ (void)stickSessinOnTop:(NSDictionary *)params
{
    NSString *sessionId = params[@"id"];
    NSNumber *type = params[@"type"];
    BOOL isTop = [params[@"isTop"] boolValue];
    
    NIMSession *session = [NIMSession session:sessionId
                                         type:type.integerValue];
    if(isTop) {
        [self addRecentSessionMark:session type:1];
    }else {
        [self removeRecentSessionMark:session type:1];
    }
}

// 开关消息通知
+ (void)changeNotifyStatus:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sessionId = params[@"id"];
    NSNumber *type = params[@"type"];
    BOOL needMsgNotify = [params[@"needNotify"] boolValue];
    
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
+ (void)quitTeam:(NSDictionary *)params
{
    NSString *teamId = params[@"teamId"];
    FlutterResult result = params[nimSDKResultKey];
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
+ (void)dismissTeam:(NSDictionary *)params
{
    NSString *teamId = params[@"teamId"];
    FlutterResult result = params[nimSDKResultKey];
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


/// 判断用户是否被拉黑
/// @param params 用户id
+ (void)isUserBlocked:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    BOOL isBlocked = [[NIMSDK sharedSDK].userManager isUserInBlackList:params[@"userId"]];
    result(@(isBlocked));
}


/// 把用户加入黑名单
/// @param params 用户ID
+ (void)blockUser:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].userManager addToBlackList:params[@"userId"]
                                        completion:^(NSError * _Nullable error) {
        if(!error) {
            result(@(YES));
        }else {
            [UIViewController showError:@"加入黑名单失败"];
            result(@(NO));
        }
    }];
}


/// 移出黑名单
/// @param params 用户ID
+ (void)cancelBlockUser:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].userManager removeFromBlackBlackList:params[@"userId"] completion:^(NSError * _Nullable error) {
        if(!error) {
            result(@(YES));
        }else {
            [UIViewController showError:@"移出黑名单失败"];
            result(@(NO));
        }
    }];
}


/// 返回黑名单列表
/// @param params 回调
+ (void)blockUserList:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSArray<NIMUser *> *users = [[NIMSDK sharedSDK].userManager myBlackList];
    if(cj_empty_array(users)) {
        // 返回空列表
        result(@[]);
    }else {
        NSArray <NSString *>*userIds = [users cj_map:^id _Nonnull(NIMUser *user) {
            return user.userId;
        }];
        
        result(userIds);
    }
}

/// 修改成员群昵称
+ (void)updateUserNickName:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager updateUserNick:params[@"userId"]
                                           newNick:params[@"nickName"]
                                            inTeam:params[@"teamId"]
                                        completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"修改昵称失败"];
            result(@(NO));
        }else {
            [UIViewController showError:@"修改昵称成功"];
            result(@(YES));
        }
    }];
}

/// 修改群名称
+ (void)updateTeamName:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager updateTeamName:params[@"teamName"]
                                            teamId:params[@"teamId"]
                                        completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"修改群名称失败"];
            result(@(NO));
        }else {
            result(@(YES));
        }
    }];
}

/// 修改群公告
+ (void)updateAnnouncement:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager updateTeamAnnouncement:params[@"announcement"]
                                                    teamId:params[@"teamId"]
                                                completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"修改群公告失败"];
            result(@(NO));
        }else {
            [UIViewController showSuccess:@"修改群公告成功"];
            result(@(YES));
        }
    }];
}

/// 添加管理员
+ (void)addTeamManagers:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager addManagersToTeam:params[@"teamId"]
                                                users:params[@"userIds"]
                                           completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"添加失败"];
            result(@(NO));
        }else {
            [UIViewController showSuccess:@"添加成功"];
            result(@(YES));
        }
    }];
}

/// 移除管理员
+ (void)removeTeamManagers:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager removeManagersFromTeam:params[@"teamId"]
                                                     users:params[@"userIds"]
                                                completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"移除失败"];
            result(@(NO));
        }else {
            [UIViewController showSuccess:@"移除成功"];
            result(@(YES));
        }
    }];
}

/// 移交群
+ (void)transformTeam:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager transferManagerWithTeam:params[@"teamId"]
                                                 newOwnerId:params[@"owner"]
                                                    isLeave:NO
                                                 completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"移交失败"];
            result(@(NO));
        }else {
            [UIViewController showSuccess:@"移交成功"];
            result(@(YES));
        }
    }];
}

/// 更新群头像
+ (void)updateTeamAvatar:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager updateTeamAvatar:params[@"avatarUrl"]
                                              teamId:params[@"teamId"]
                                          completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"更新头像失败"];
            result(@(NO));
        }else {
            [UIViewController showSuccess:@"更新头像成功"];
            result(@(YES));
        }
    }];
}

/// 上传文件到云信
+ (void)uploadFileToNim:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].resourceManager upload:params[@"filePath"]
                                      progress:^(float progress) {
        
    } completion:^(NSString * _Nullable urlString, NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"上传失败"];
        }
        result(urlString);
    }];
}

/// 删除好友
+ (void)deleteContact:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    
    [[NIMSDK sharedSDK].userManager deleteFriend:params[@"userId"] removeAlias:YES completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"删除失败"];
            result(@(NO));
        }else {
            [UIViewController showSuccess:@"删除成功"];
            result(@(YES));
        }
    }];
}

/// 允许用户新消息通知
+ (void)allowUserMsgNotify:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    bool state = params[@"allowNotify"];
    NSString *userId = params[@"userId"];
    [[NIMSDK sharedSDK].userManager updateNotifyState:state forUser:userId completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:@"修改失败"];
            result(@(NO));
        }else {
            result(@(YES));
        }
    }];
}

/// 获取系统通知
+ (void)fetchSystemNotifications:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSArray <NIMSystemNotification *>*notifications = [[NIMSDK sharedSDK].systemNotificationManager fetchSystemNotifications:nil limit:MAXFLOAT];
    
    NSArray *notis = [notifications cj_map:^id _Nonnull(NIMSystemNotification *notification) {
        id attachment = notification.attachment;
        if([attachment isKindOfClass:NIMUserAddAttachment.class]) {
            attachment = @(((NIMUserAddAttachment *)notification.attachment).operationType);
        }
        return @{
            @"notificationId": @(notification.notificationId),
            @"type": @(notification.type),
            @"timestamp": @(notification.timestamp),
            @"sourceID": notification.sourceID?:[NSNull null],
            @"targetID": notification.targetID?:[NSNull null],
            @"postscript": notification.postscript?:[NSNull null],
            @"read": @(notification.read),
            @"handleStatus": @(notification.handleStatus),
            @"notifyExt": notification.notifyExt?:[NSNull null],
            @"attachment": attachment?:[NSNull null]
        };
    }];
    
    result(notis);
}

/// 删除所有通知
+ (void)deleteAllNotifications
{
    [[[NIMSDK sharedSDK] systemNotificationManager] deleteAllNotifications];
}

/// 申请进群
+ (void)applyToTeam:(NSDictionary *)params
{
    NSString *teamId = params[@"teamId"];
    NSString *verifyMsg = params[@"verifyMsg"];
    FlutterResult result = params[nimSDKResultKey];
    [[NIMSDK sharedSDK].teamManager applyToTeam:teamId
                                        message:verifyMsg ?:@"通过扫码方式申请进群"
                                     completion:^(NSError * _Nullable error, NIMTeamApplyStatus applyStatus) {
        
        if(!error) {
            if(applyStatus == NIMTeamApplyStatusInvalid) {
                [UIViewController showError:@"无效状态"];
                result(@(NO));
            }else if(applyStatus == NIMTeamApplyStatusAlreadyInTeam) {
                [UIViewController showSuccess:@"进群成功"];
                result(@(YES));
            }else if(applyStatus == NIMTeamApplyStatusWaitForPass) {
                [UIViewController showSuccess:@"申请成功，等待验证"];
                result(@(NO));
            }
        }else {
            switch (error.code) {
                case NIMRemoteErrorCodeTeamAlreadyIn:
                    [UIViewController showError:@"你已经在群里，请勿重复申请"];
                    result(@(NO));
                    break;
                default:
                    [UIViewController showError:@"群申请失败"];
                    result(@(NO));
                    break;
            }
        }
    }];
}

/// 同意入群申请
+ (void)passApplyToTeam:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *targetID = params[@"targetID"];
    NSString *sourceID = params[@"sourceID"];
    [[NIMSDK sharedSDK].teamManager passApplyToTeam:targetID userId:sourceID completion:^(NSError * _Nullable error, NIMTeamApplyStatus applyStatus) {
        if (!error) {
            [UIViewController showSuccess:@"同意成功"];
            result(@(1));
        }else {
            if(error.code == NIMRemoteErrorCodeTimeoutError) {
                [UIViewController showError:@"网络问题，请重试"];
                result(@(0));
            } else {
                [UIViewController showError:@"请求已失效"];
                result(@(3));
            }
        }
    }];
}

/// 拒绝入群申请
+ (void)rejectApplyToTeam:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sourceID = params[@"sourceID"];
    NSString *targetID = params[@"targetID"];
    [[NIMSDK sharedSDK].teamManager rejectApplyToTeam:targetID userId:sourceID rejectReason:@"" completion:^(NSError * _Nullable error) {
        if (!error) {
            [UIViewController showSuccess:@"拒绝成功"];
            result(@2);
        }else {
            if(error.code == NIMRemoteErrorCodeTimeoutError) {
                [UIViewController showError:@"网络问题，请重试"];
                result(@(0));
            } else {
                [UIViewController showError:@"请求已失效"];
                result(@(3));
            }
        }
    }];
}

/// 接受入群邀请
+ (void)acceptInviteWithTeam:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sourceID = params[@"sourceID"];
    NSString *targetID = params[@"targetID"];
    [[NIMSDK sharedSDK].teamManager acceptInviteWithTeam:targetID invitorId:sourceID completion:^(NSError * _Nullable error) {
        if (!error) {
            [UIViewController showSuccess:@"接受成功"];
            result(@(1));
        }else {
            if(error.code == NIMRemoteErrorCodeTimeoutError) {
                [UIViewController showError:@"网络问题，请重试"];
                result(@(0));
            }
            else if (error.code == NIMRemoteErrorCodeTeamNotExists) {
                [UIViewController showError:@"群不存在"];
                result(@(3));
            }
            else {
                [UIViewController showError:@"请求已失效"];
                result(@(3));
            }
        }
    }];
}

/// 拒绝入群邀请
+ (void)rejectInviteWithTeam:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sourceID = params[@"sourceID"];
    NSString *targetID = params[@"targetID"];
    [[NIMSDK sharedSDK].teamManager rejectInviteWithTeam:targetID invitorId:sourceID rejectReason:@"" completion:^(NSError * _Nullable error) {
        if (!error) {
            [UIViewController showSuccess:@"拒绝成功"];
            result(@2);
        }else {
            if(error.code == NIMRemoteErrorCodeTimeoutError) {
                [UIViewController showError:@"网络问题，请重试"];
                result(@(0));
            }
            else if (error.code == NIMRemoteErrorCodeTeamNotExists) {
                [UIViewController showError:@"群不存在"];
                result(@(3));
            }
            else {
                [UIViewController showError:@"请求已失效"];
                result(@(3));
            }
        }
    }];
}

/// 通过添加好友请求
+ (void)requestFriend:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sourceID = params[@"sourceID"];
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    request.userId = sourceID;
    request.operation = NIMUserOperationVerify;
        
    [[[NIMSDK sharedSDK] userManager] requestFriend:request
                                         completion:^(NSError *error)
    {
         if (!error) {
              NIMSession *session = [NIMSession session:sourceID type:NIMSessionTypeP2P];
            
             NSString *messageContent = [NSString stringWithFormat:@"你好，我们已加为好友!"];
             NIMMessage *message = [NIMMessageMaker msgWithText:messageContent];
            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
             [UIViewController showSuccess:@"添加成功"];
             result(@(1));
         }
         else
         {
             [UIViewController showError:@"添加失败,请重试"];
             result(@0);
         }
     }];
}

/// 拒绝好友添加申请
+ (void)rejectFriendRequest:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *sourceID = params[@"sourceID"];
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    request.userId = sourceID;
    request.operation = NIMUserOperationReject;
    
    [[[NIMSDK sharedSDK] userManager] requestFriend:request
                                         completion:^(NSError *error) {
                                             if (!error) {
                                                 [UIViewController showSuccess:@"拒绝成功"];
                                                 result(@2);
                                             }
                                             else
                                             {
                                                 [UIViewController showError:@"验证失败,请重试"];
                                                 result(@0);
                                             }
                                         }];
}

/// 是否是我的好友
+ (void)isMyFriend:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NSString *userId = params[@"userId"];
    bool isMyFriend = [[NIMSDK sharedSDK].userManager isMyFriend:userId];
    result(@(isMyFriend));
}

/// 修改好友信息 目前支持修改备注
+ (void)updateUser:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:params[@"userId"]];
    user.alias = params[@"alias"];
    [[NIMSDK sharedSDK].userManager updateUser:user completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:[NSString stringWithFormat:@"修改失败:%@", error.description]];
            result(@(NO));
        }else {
            [UIViewController showError:@"修改成功"];
            result(@(YES));
        }
    }];
}

/// 修改个人资料
+ (void)updateMyInfo:(NSDictionary *)params
{
    FlutterResult result = params[nimSDKResultKey];
    NIMUserInfoUpdateTag tag = [params[@"tag"] integerValue];
    NSString *avatarUrl = params[@"avatarUrl"];
    NSString *nickName = params[@"nickName"];
    NSNumber *gender = params[@"gender"];
    NSString *birth = params[@"birth"];
    NSString *email = params[@"email"];
    NSString *sign = params[@"sign"];
    NSString *phone = params[@"phone"];
    NSString *ext = params[@"ext"];
    
    id p = [NSNull null];
    if(tag == NIMUserInfoUpdateTagNick) p = nickName;
    if(tag == NIMUserInfoUpdateTagAvatar) p = avatarUrl;
    if(tag == NIMUserInfoUpdateTagGender) p = gender;
    if(tag == NIMUserInfoUpdateTagBirth) p = birth;
    if(tag == NIMUserInfoUpdateTagEmail) p = email;
    if(tag == NIMUserInfoUpdateTagSign) p = sign;
    if(tag == NIMUserInfoUpdateTagMobile) p = phone;
    if(tag == NIMUserInfoUpdateTagExt) p = ext;
    [[NIMSDK sharedSDK].userManager updateMyUserInfo:@{@(tag) : p}
                                          completion:^(NSError * _Nullable error) {
        if(error) {
            [UIViewController showError:[NSString stringWithFormat:@"修改失败:%@", error.description]];
            result(@(NO));
        }else {
            [UIViewController showError:@"修改成功"];
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
