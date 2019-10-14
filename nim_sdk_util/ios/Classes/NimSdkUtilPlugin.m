#import "NimSdkUtilPlugin.h"
#import <NIMKit.h>
#import <CJBase/CJBase.h>

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
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:accid option:nil];
    NIMUser *me = [[NIMSDK sharedSDK].userManager userInfo:accid];
    NSDictionary *cjExt = JsonStringDecode(me.userInfo.ext);
    result(@{
            @"name": info.showName,
            @"avatarUrl": info.avatarUrlString,
            @"cajian_no": cjExt[@"cajian_id"]?:@""
            });
}

// 返回群信息
+ (void)teamInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NIMKitInfo *info = [[NIMKit sharedKit] infoByTeam:params.firstObject
                                               option:nil];
    result(@{
            @"show_name": info.showName,
            @"avatar_url_string": info.avatarUrlString?: [NSNull new],
            // @"avatar_image": info.avatarImage?: [NSNull new]
            });
}

// 返回用户信息
+ (void)userInfo:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:params.firstObject
                                               option:nil];
    result(@{
            @"show_name": info.showName,
            @"avatar_url_string": info.avatarUrlString?: [NSNull new],
            // @"avatar_image": info.avatarImage?: [NSNull new]
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

<<<<<<< Updated upstream
// 群聊列表
+ (void)allMyTeams:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSMutableArray *teamInfos = @[].mutableCopy;
    for (NIMTeam *team in [NIMSDK sharedSDK].teamManager.allMyTeams) {
        [teamInfos addObject:@{
            @"teamId": team.teamId,
            @"teamName": team.teamName,
            @"teamAvatar": team.avatarUrl
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
                @"invitor": member.invitor,
                @"inviterAccid": member.inviterAccid,
                @"type": @(member.type),
                @"showName": member.nickname,
                @"isMuted": @(member.isMuted),
                @"createTime": @(member.createTime),
                @"customInfo": member.customInfo
            }];
            
            if(member == members.lastObject) {
                result(teamMemberInfos);
                return;
            }
        }
        // 没有成员或者error了
        result(@[]);
    }];
=======
//***-----TF------***
// 返回当前登录用户信息
+ (void)currentUser:(NSArray *)params
{
    FlutterResult result = params.lastObject;
    NSString *accid = [NIMSDK sharedSDK].loginManager.currentAccount;
    NIMUserInfo *user = [[NIMSDK sharedSDK].userManager userInfo:accid].userInfo;
    NSDictionary *cjExt = JsonStringDecode(user.ext);
    result(@{
             @"nickName": user.nickName ? : @"",
             @"avatarUrl": user.avatarUrl ? : @"",
             @"thumbAvatarUrl" : user.thumbAvatarUrl ? : @"",
             @"sign" : user.sign ? : @"",
             @"gender": @(user.gender),
             @"email": user.email ? : @"",
             @"birth": user.birth ? : @"",
             @"mobile": user.mobile ? : @"",
             @"ext": cjExt[@"cajian_id"]?:@"",
             });
>>>>>>> Stashed changes
}

@end
