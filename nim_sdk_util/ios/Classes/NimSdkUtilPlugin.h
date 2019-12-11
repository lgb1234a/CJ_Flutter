#import <Flutter/Flutter.h>

@interface NimSdkUtilPlugin : NSObject<FlutterPlugin>

/**
 注册云信SDK
 */
+ (void)registerSDK;


/**
 云信登出
 */
+ (void)logout;


/// 自动登录
/// @param accid id
/// @param token token
+ (void)autoLogin:(NSString *)accid
            token:(NSString *)token;


/// 登录
/// @param params 参数  accid   token
+ (void)doLogin:(NSDictionary *)params;

@end
