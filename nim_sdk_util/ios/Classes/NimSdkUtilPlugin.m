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
             [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess"
                                                                 object:self];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess"
                                                        object:self];
}

+ (void)autoLogin:(NSString *)accid token:(NSString *)token
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

// 返回当前登录用户信息
+ (void)currentUserInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *accid = [NIMSDK sharedSDK].loginManager.currentAccount;
    NIMUserInfo *user = [[NIMSDK sharedSDK].userManager userInfo:accid].userInfo;
    NSDictionary *cjExt = JsonStringDecode(user.ext);
    result(@{
             @"showName": user.nickName ? : @"",
             @"avatarUrlString": user.avatarUrl ? : @"",
             @"thumbAvatarUrl" : user.thumbAvatarUrl ? : @"",
             @"sign" : user.sign ? : @"",
             @"gender": @(user.gender),
             @"email": user.email ? : @"",
             @"birth": user.birth ? : @"",
             @"mobile": user.mobile ? : @"",
             @"cajianNo": cjExt[@"cajian_id"]?:@"",
             });
}

// 返回群信息
+ (void)teamInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NIMKitInfo *info = [[NIMKit sharedKit] infoByTeam:params.firstObject
                                               option:nil];
    
    result(@{
            @"showName": info.showName,
            @"avatarUrlString": info.avatarUrlString?: [NSNull new],
             @"avatarImage": [FlutterStandardTypedData typedDataWithBytes:UIImagePNGRepresentation(info.avatarImage)]
            });
}

// 返回用户信息
+ (void)userInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:params.firstObject
                                               option:nil];
    
    result(@{
            @"showName": info.showName,
            @"avatarUrlString": info.avatarUrlString?: [NSNull new],
             @"avatarImage": [FlutterStandardTypedData typedDataWithBytes:UIImagePNGRepresentation(info.avatarImage)]
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
                                  @"infoId": info.infoId,
                                  @"showName": info.showName,
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
            @"teamId": team.teamId,
            @"teamName": team.teamName,
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
                @"teamId": member.teamId,
                @"userId": member.userId,
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
    BOOL notifyForNewMsg = [[NIMSDK sharedSDK].userManager notifyForNewMsg:sessionId];
    
    result(@(notifyForNewMsg));
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


@end
