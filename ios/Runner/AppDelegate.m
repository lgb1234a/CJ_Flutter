#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJUtilBridge.h"
#import "CJViewController.h"
#import "WeChatManager.h"
#import "CJSessionListViewController.h"
#import "CJContactsViewController.h"
#import "CJViewController.h"
#import "CJMineViewController.h"
#import <nim_sdk_util/NimSdkUtilPlugin.h>

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
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onResp:(BaseResp*)resp{
    // 分享成功是否的监听
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if(resp.errCode == 0){
            
        }
    }
    // 授权结果监听
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        if (resp.errCode == 0) {
            SendAuthResp *_resp = (SendAuthResp*)resp;
            NSString* accessToekn =  _resp.code;
            ZZLog(@"WetChat AccessToken %@", accessToekn);
            // 拿到TOKEN后去服务端认证下
            if ([_resp.state isEqualToString:@"get_access_token_bind"]) {
                [WeChatManager wxBindCode:accessToekn];
            }else{
                // 拿到TOKEN后去服务端认证下
                [WeChatManager sendLoginAuth:accessToekn result:^(BaseModel *model) {
                    [self onWxLoginResp:model code:accessToekn];
                }];
            }
        }
        else
        {
            [UIViewController showError:@"用户取消或者拒绝了微信授权登录"];
        }
    }
}

- (void)onWxLoginResp:(BaseModel *)model code:(NSString *)code
{
    if (model.success)
    {
        NSString *account = [model.data objectForKey:@"accid"];
        NSString *token   = [model.data objectForKey:@"token"];
        // 直接登录
        [[NIMSDK sharedSDK].loginManager login:account
                                         token:token
                                    completion:^(NSError * _Nullable error)
        {
            if(!error) {
                [UIViewController showSuccess:@"登录成功"];
                [self showDidLoginSuccessRootVC];
            }
        }];
    }else if ([model.error isEqualToString:@"1"]){
        [UIViewController hideHUD];
        // 显示绑定手机页面
        // 保存下unionid headimage nickname 保存到WeChatManager上面吧
        NSDictionary* strData = model.data;
        if (strData != nil) {
//            NSString* str_union_id  = [strData objectForKey:@"union_id"];
//            NSString* str_headimg   = [strData objectForKey:@"head_img"];
//            NSString* str_nick_name = [strData objectForKey:@"nick_name"];
//            [WeChatManager sharedManager].code = code;
//            [WeChatManager sharedManager].union_id = str_union_id;
//            [WeChatManager sharedManager].headimage = str_headimg;
//            [WeChatManager sharedManager].nickname = str_nick_name;
        }
//        BindPhoneViewController *vc = [BindPhoneViewController new];
//        [_mainViewController.navigationController pushViewController:vc animated:YES];
    }else if([model.error isEqualToString:@"8"])
    {
        [UIViewController hideHUD];
        // 账号冻结了
//        [LoginTaskManager unfreezeAccount];
    }
    else{
        [UIViewController hideHUD];
        [UIViewController showError:model.errmsg];
    }
}

// 展示登录成功的页面根视图
- (void)showDidLoginSuccessRootVC
{
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    
    CJSessionListViewController *listVC = [[CJSessionListViewController alloc] init];
    UINavigationController *listNav = [[UINavigationController alloc] initWithRootViewController:listVC];
    listNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"擦肩"
                                                       image:[UIImage imageNamed:@"icon_message_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_message_pressed"]];
    listNav.tabBarItem.tag = 0;
    
    CJContactsViewController *contactsVC = [[CJContactsViewController alloc] init];
    UINavigationController *contactsNav = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    contactsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                       image:[UIImage imageNamed:@"icon_contact_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_contact_pressed"]];
    contactsNav.tabBarItem.tag = 1;
    
    CJMineViewController *mine = [CJMineViewController new];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mine];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我"
                                                       image:[UIImage imageNamed:@"icon_setting_normal"]
                                               selectedImage:[UIImage imageNamed:@"icon_setting_pressed"]];
    mineNav.tabBarItem.tag = 2;
    
    tabbar.viewControllers = @[listNav, contactsNav, mineNav];
    
    self.window.rootViewController = tabbar;
    
    [self registerChannel:mine];
}

// 展示登出成功的页面根视图
- (void)showDidLogoutRootVC
{
    NSString *openUrl = @"{\"route\":\"login_entrance\",\"channel_name\":\"com.zqtd.cajian/login_entrance\"}";
    CJViewController *rootVC = [[CJViewController alloc] initWithInitialOpenUrl:openUrl];
    self.window.rootViewController = rootVC;
    
    [self registerChannel:rootVC];
}

- (void)registerChannel:(CJViewController *)rootVC
{
    __weak typeof(self) weakSelf = self;
    
    _utilChannel = [FlutterMethodChannel
                         methodChannelWithName:@"com.zqtd.cajian/util"
                         binaryMessenger:rootVC.engine.binaryMessenger];
    
    [_utilChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        SEL callMethod = NSSelectorFromString(call.method);
        if([weakSelf respondsToSelector:callMethod])
        {
            [weakSelf performSelector:callMethod
                           withObject:call.arguments
                           afterDelay:0];
        }else {
            [CJUtilBridge bridgeCall:call result:result];
        }
    }];
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
    // 登出
    [_utilChannel invokeMethod:@"logout" arguments:nil];
    
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
