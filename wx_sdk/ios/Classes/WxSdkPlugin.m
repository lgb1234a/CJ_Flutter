#import "WxSdkPlugin.h"
//#import <CJBase/CJBase.h>

@implementation WxSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"wx_sdk"
            binaryMessenger:[registrar messenger]];
  WxSdkPlugin* instance = [[WxSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
      SEL sel = NSSelectorFromString(call.method);
      if([WxSdkPlugin respondsToSelector:sel]) {
          NSArray *params = call.arguments;
          NSMutableArray *p = params?params.mutableCopy : @[].mutableCopy;
          [p addObject:result];
          [WxSdkPlugin performSelector:sel
                            withObject:p
                            afterDelay:0];
      }else {
          result(FlutterMethodNotImplemented);
      }
  }
}

+ (void)wxlogin
{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq* req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"get_access_token";
        [WXApi sendReq:req];
    }
}

@end
