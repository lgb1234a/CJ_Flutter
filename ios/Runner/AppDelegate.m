#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJViewController.h"
#import "CJSessionListViewController.h"
#import "CJContactsViewController.h"
#import "CJViewController.h"
#import "CJMineViewController.h"
#import <nim_sdk_util/NimSdkUtilPlugin.h>
#import <WxSdkPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化flutter
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [WXApi registerApp:@"wx0f56e7c5e6daa01a"];
    [NimSdkUtilPlugin registerSDK];
    /*根据登录状态初始化登录页面 vc*/
    [self showDidLogoutRootVC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDidLoginSuccessRootVC)
                                                 name:@"loginSuccess"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDidLogoutRootVC)
                                                 name:@"didLogout"
                                               object:nil];
    /* 登录回调代理 */
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WxSdkPlugin new]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:[WxSdkPlugin new]];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:[WxSdkPlugin new]];
}

// 展示登录成功的页面根视图
- (void)showDidLoginSuccessRootVC
{
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    
    CJSessionListViewController *listVC = [[CJSessionListViewController alloc] init];
    CJNavigationViewController *listNav = [[CJNavigationViewController alloc] initWithRootViewController:listVC];
    listNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"擦肩"
                                                       image:[UIImage imageNamed:@"icon_message_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_message_pressed"]];
    listNav.tabBarItem.tag = 0;
    
    CJContactsViewController *contactsVC = [[CJContactsViewController alloc] init];
    CJNavigationViewController *contactsNav = [[CJNavigationViewController alloc] initWithRootViewController:contactsVC];
    contactsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                       image:[UIImage imageNamed:@"icon_contact_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_contact_pressed"]];
    contactsNav.tabBarItem.tag = 1;
    
    CJMineViewController *mine = [CJMineViewController new];
    CJNavigationViewController *mineNav = [[CJNavigationViewController alloc] initWithRootViewController:mine];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我"
                                                       image:[UIImage imageNamed:@"icon_setting_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_setting_pressed"]];
    mineNav.tabBarItem.tag = 2;
    
    tabbar.viewControllers = @[listNav, contactsNav, mineNav];
    
    self.window.rootViewController = tabbar;
}

// 展示登出成功的页面根视图
- (void)showDidLogoutRootVC
{
    NSString *openUrl = @"{\"route\":\"login_entrance\",\"channel_name\":\"com.zqtd.cajian/login_entrance\"}";
    CJViewController *rootVC = [[CJViewController alloc] initWithFlutterOpenUrl:openUrl];
    self.window.rootViewController = rootVC;
}

#pragma mark - NIMLoginManagerDelegate

- (void)onKick:(NIMKickReason)code
    clientType:(NIMLoginClientType)clientType
{
    NSString *reason = @"你被踢下线";
    switch (code) {
        case NIMKickReasonByClient:
        case NIMKickReasonByClientManually:{
            reason = @"你的帐号被踢出下线，请注意帐号信息安全";
            break;
        }
        case NIMKickReasonByServer:
            reason = @"你已被服务器踢下线";
            break;
        default:
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚠️"
                                                                   message:reason
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [NimSdkUtilPlugin logout];
                                            }]];
    [self.window.rootViewController presentViewController:alert
                                                 animated:YES
                                               completion:nil];
}

@end
