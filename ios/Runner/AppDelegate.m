#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJViewController.h"
#import "CJSessionListViewController.h"
#import "CJContactsViewController.h"
#import "CJViewController.h"
#import "CJMineViewController.h"
#import <nim_sdk_util/NimSdkUtilPlugin.h>
#import <WxSdkPlugin.h>
#import "CJCustomAttachmentDecoder.h"
#import "CJCellLayoutConfig.h"
#import "CJNotificationCenter.h"
#import "CJPayManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化flutter
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // 注册微信sdk
    [WXApi registerApp:@"wx0f56e7c5e6daa01a"];
    // 配置云信服务
    [self configNIMServices];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogout)
                                                 name:@"didLogout"
                                               object:nil];
    /* 登录回调代理 */
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    /*根据登录状态初始化登录页面 vc*/
    NSString *accid = [[NSUserDefaults standardUserDefaults] objectForKey:@"flutter.accid"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"flutter.token"];
    if(accid && token) {
        [NimSdkUtilPlugin autoLogin:accid token:token];
    }else {
        [self showDidLogoutRootVC];
    }
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)configNIMServices
{
    // 注册云信sdk
    [NimSdkUtilPlugin registerSDK];
    //注册自定义消息的解析器
    [NIMCustomObject registerCustomDecoder:[CJCustomAttachmentDecoder new]];
    //注入 NIMKit 自定义排版配置
    [[NIMKit sharedKit] registerLayoutConfig:[CJCellLayoutConfig new]];
    //启动消息通知
    [[CJNotificationCenter sharedCenter] start];
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

#pragma mark - 登录，这里只做UI和第三方库处理

- (void)didLogout
{
    // 接收通知回调
    [[CJPayManager sharedManager] didLogout];
    
    [self showDidLogoutRootVC];
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
    
    CJMineViewController *mine = [[CJMineViewController alloc] init];
    CJNavigationViewController *mineNav = [[CJNavigationViewController alloc] initWithRootViewController:mine];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我"
                                                       image:[UIImage imageNamed:@"icon_setting_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_setting_pressed"]];
    mineNav.tabBarItem.tag = 2;
    
    tabbar.viewControllers = @[listNav, contactsNav, mineNav];
    
    self.window.rootViewController = tabbar;
    self.tabbar = tabbar;
}

// 展示登出成功的页面根视图
- (void)showDidLogoutRootVC
{
    NSString *openUrl = @"{\"route\":\"login_entrance\",\"channel_name\":\"com.zqtd.cajian/login_entrance\"}";
    CJViewController *rootVC = [[CJViewController alloc] initWithFlutterOpenUrl:openUrl];
    self.window.rootViewController = rootVC;
}

#pragma mark - NIMLoginManagerDelegate

- (void)onLogin:(NIMLoginStep)step
{
    switch (step) {
        case NIMLoginStepLinking:
            [UIViewController showLoadingWithMessage:@"正在连接服务器～"];
            break;
        case NIMLoginStepLinkFailed:
            [UIViewController showError:@"连接服务器失败"];
            break;
        case NIMLoginStepLoginOK:
            [[CJPayManager sharedManager] didLogin];
            [self showDidLoginSuccessRootVC];
            break;
        case NIMLoginStepLoginFailed:
            [UIViewController showError:@"登录失败"];
            break;
            break;
        default:
            break;
    }
    
}

- (void)onAutoLoginFailed:(NSError *)error
{
    [self showDidLogoutRootVC];
}

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
    // 登出逻辑
    [NimSdkUtilPlugin logout];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚠️"
                                                                   message:reason
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self.window.rootViewController presentViewController:alert
                                                 animated:YES
                                               completion:nil];
}

@end
