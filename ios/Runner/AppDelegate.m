#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJFlutterViewController.h"
#import "CJLoginViewController.h"
#import "CJFlutterViewController.h"
#import <nim_sdk_util/NimSdkUtilPlugin.h>
#import <WxSdkPlugin.h>
#import "CJCustomAttachmentDecoder.h"
#import "CJCellLayoutConfig.h"
#import "CJNotificationCenter.h"
#import "CJPayManager.h"
#import "PlatformRouterImp.h"
#import "CJUtilBridge.h"
#import "CJTabbarControllerController.h"

@interface AppDelegate ()

@property (nonatomic, strong)PlatformRouterImp *router;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
    
    // 初始化flutter
    _router = [PlatformRouterImp new];
    [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:_router
                                                        onStart:^(FlutterEngine *engine) {
        [[CJUtilBridge alloc] initBridge];
    }];
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
    CJTabbarControllerController *tabbar = [[CJTabbarControllerController alloc] initWithRootViewControllers];
    
    CJNavigationViewController *root = [[CJNavigationViewController alloc] initWithRootViewController:tabbar];
    
    self.window.rootViewController = root;
    self.tabbar = tabbar;
    
    _router.navigationController = root;
}

// 展示登出成功的页面根视图
- (void)showDidLogoutRootVC
{
    CJLoginViewController *loginVC = [[CJLoginViewController alloc] init];
    CJNavigationViewController *root = [[CJNavigationViewController alloc] initWithRootViewController:loginVC];
    
    self.window.rootViewController = root;
    _router.navigationController = root;
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
