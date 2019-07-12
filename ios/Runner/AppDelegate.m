#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

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
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
