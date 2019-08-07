#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJNIMSDKBridge.h"
#import "CJUtilBridge.h"
#import "CJViewController.h"
#import "CJNIMSDKBridge.h"
#import "WeChatManager.h"
#import "CJSessionListViewController.h"
#import "CJContactsViewController.h"
#import "CJViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 注册云信SDK
    [CJNIMSDKBridge registerSDK];
    [WXApi registerApp:@"wx0f56e7c5e6daa01a"];
    
    // 初始化flutter
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
        SEL callMethod = NSSelectorFromString(call.method);
        if([self respondsToSelector:callMethod])
        {
            [self performSelector:callMethod
                       withObject:call.arguments
                       afterDelay:0];
        }else {
            [CJNIMSDKBridge bridgeCall:call result:result];
        }
    }];
    
    FlutterMethodChannel *utilChannel = [FlutterMethodChannel
                                        methodChannelWithName:@"com.zqtd.cajian/util"
                                        binaryMessenger:controller.engine.binaryMessenger];
    
    [utilChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        SEL callMethod = NSSelectorFromString(call.method);
        if([self respondsToSelector:callMethod])
        {
            [self performSelector:callMethod
                       withObject:call.arguments
                       afterDelay:0];
        }else {
            [CJUtilBridge bridgeCall:call result:result];
        }
    }];
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
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NIMLoginSuccess"
                                                                    object:nil];
                [self loginSuccess];
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

- (void)loginSuccess
{
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    
    CJSessionListViewController *listVC = [[CJSessionListViewController alloc] init];
    UINavigationController *listNav = [[UINavigationController alloc] initWithRootViewController:listVC];
    
    CJContactsViewController *contactsVC = [[CJContactsViewController alloc] init];
    UINavigationController *contactsNav = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    
    NSString *mineOpenUrl = @"{\"route\":\"mine\",\"channel_name\":\"com.zqtd.cajian/mine\"}";
    CJViewController *mine = [[CJViewController alloc] initWithInitialOpenUrl:mineOpenUrl];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mine];
    
    tabbar.viewControllers = @[listNav, contactsNav, mineNav];
    
    self.window.rootViewController = tabbar;
}

@end
