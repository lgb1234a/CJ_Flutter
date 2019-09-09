#import "WxSdkPlugin.h"
#import <CJBase/CJBase.h>
#import <NIMKit/NIMKit.h>

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
                [WxSdkPlugin wxBindCode:accessToekn];
            }else{
                // 拿到TOKEN后去服务端认证下
                [WxSdkPlugin sendLoginAuth:accessToekn
                                    result:^(BaseModel *model)
                {
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
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess"
                                                                     object:self];
                 
                 // 持久化accid和token
                 [self stashLoginInfo:account token:token];
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


- (void)stashLoginInfo:(NSString *)accid token:(NSString *)token
{
    // 加上前缀flutter. 和flutter插件sp保持一致，可以被flutter端读取
    [[NSUserDefaults standardUserDefaults] setValue:accid forKey:@"flutter.accid"];
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"flutter.token"];
}

+ (void)wxBindCode:(NSString *)code
{
    NSString *url =  [NSString stringWithFormat:@"%@/g2/user/wx/bind",kBaseUrl];
    NSString *accid = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NSDictionary *params = @{@"accid":accid ? : @"",
                             @"code":code ? : @"",
                             @"union_id":@"",
                             @"app_key":@"wx0f56e7c5e6daa01a"};
    [UIViewController showWaiting];
    
    [HttpHelper postWithURL:url params:params success:^(BaseModel * _Nonnull model) {
        
        [UIViewController hideHUD];
        if (model.success) {
            [UIViewController showSuccess:@"绑定成功"];
        }else{
            [UIViewController showError:model.errmsg];
        }
    } failure:^(NSError * _Nonnull error) {
    }];
}

+ (void)sendLoginAuth:(NSString*)accessToken
               result:(void (^)(BaseModel *model))result
{
    ZZLog(@"sendLoginAuth  accessToken  %@", accessToken);
    //加入参数
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:accessToken forKey:@"code"];
    [params setValue:@"wx0f56e7c5e6daa01a" forKey:@"app_key"];
    [UIViewController showLoadingWithMessage:@"登录中..."];
    [HttpHelper postWithURL:kWechatLoginUrl
                     params:params
                    success:^(BaseModel * _Nonnull model)
     {
         if (result) {
             result(model);
         }
         else
         {
             [UIViewController hideHUD];
             ZZLog(@"_loginDelegate is nil");
         }
     } failure:^(NSError * _Nonnull error) {
         
         //        [UIViewController hideHUD];
     }];
}

@end
