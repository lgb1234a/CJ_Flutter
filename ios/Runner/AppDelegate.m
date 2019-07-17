#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJNIMSDKBridge.h"

const NSMutableArray <NSString *>*channels() {
    static dispatch_once_t onceToken;
    static NSMutableArray <NSString *>*chs = nil;
    dispatch_once(&onceToken, ^{
        if(chs == nil) {
            chs = @[].mutableCopy;
        }
    });
    return chs;
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
    FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel *nimChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.zqtd.cajian/NIMSDK"
                                            binaryMessenger:controller.engine.binaryMessenger];
    
    [nimChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        [CJNIMSDKBridge bridgeCall:call result:result];
    }];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
