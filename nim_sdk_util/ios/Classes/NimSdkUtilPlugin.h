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

@end
