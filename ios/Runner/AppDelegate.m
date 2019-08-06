#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJNIMSDKBridge.h"
#import "CJUtilBridge.h"
#import "CJViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
    FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
    
    
    /*初始化root vc*/
    NSString *openUrl = @"{\"route\":\"login_entrance\",\"channel_name\":\"com.zqtd.cajian/login_entrance\"}";
    CJViewController *rootVC = [[CJViewController alloc] initWithInitialOpenUrl:openUrl];
    self.window.rootViewController = rootVC;
    
    FlutterMethodChannel *nimChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.zqtd.cajian/NIMSDK"
                                            binaryMessenger:controller.engine.binaryMessenger];
    
    [nimChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        [CJNIMSDKBridge bridgeCall:call result:result];
    }];
    
    FlutterMethodChannel *utilChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"com.zqtd.cajian/util"
                                        binaryMessenger:controller.engine.binaryMessenger];
    
    [utilChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        [CJUtilBridge bridgeCall:call result:result];
    }];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
