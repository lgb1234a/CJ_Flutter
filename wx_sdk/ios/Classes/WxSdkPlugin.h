#import <Flutter/Flutter.h>
#import <WXApi.h>
@class BaseModel;

@interface WxSdkPlugin : NSObject<FlutterPlugin, WXApiDelegate>

// 绑定微信
+ (void)wxBindCode:(NSString *)code;

// 登录授权
+ (void)sendLoginAuth:(NSString*)accessToken
               result:(void (^)(BaseModel *model))result;

@end
