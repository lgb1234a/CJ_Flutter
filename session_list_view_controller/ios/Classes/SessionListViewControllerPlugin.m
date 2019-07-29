#import "SessionListViewControllerPlugin.h"
#import "FlutterSessionListViewController.h"
#import "FlutterSessionViewController.h"

@implementation SessionListViewControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
    // 注册flutter platform view
    [registrar registerViewFactory:[[FlutterSessionListViewControllerFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins/session_list"];
    [registrar registerViewFactory:[[FlutterSessionViewControllerFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins/session"];
    
    FlutterMethodChannel *channel_1 = [FlutterMethodChannel
      methodChannelWithName:@"session_list_view_controller"
            binaryMessenger:[registrar messenger]];
    SessionListViewControllerPlugin *instance_1 = [[SessionListViewControllerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance_1 channel:channel_1];
    
    
    FlutterMethodChannel *channel_2 = [FlutterMethodChannel
                                     methodChannelWithName:@"session_view_controller"
                                     binaryMessenger:[registrar messenger]];
    SessionListViewControllerPlugin* instance_2 = [[SessionListViewControllerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance_2 channel:channel_2];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
