#import "WxSdkPlugin.h"
#import <CJBase/CJBase.h>
#import <NIMKit/NIMKit.h>
#import "FlutterBoost.h"
#import "NimSdkUtilPlugin.h"

static NSString *wxSDKResultKey = @"flutter_result";

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
          NSDictionary *params = call.arguments;
          NSMutableDictionary *p = params?params.mutableCopy : @{}.mutableCopy;
          [p setObject:result forKey:wxSDKResultKey];
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

/// 分享到微信
/// web:12
+ (void)share:(NSDictionary *)params
{
    WXMediaMessage *message = [WXMediaMessage message];
    NSString *title = params[@"title"];
    NSString *content = params[@"content"];
    NSString *url = params[@"url"];
    NSNumber *type = params[@"type"];
    if (title == nil) {
        message.title = @"";
    }
    else
    {
        message.title = title;
    }
    message.description     = content;
    message.messageExt      = content;
    message.messageAction   = content;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
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
            NSString* accessToken =  _resp.code;
            ZZLog(@"WetChat AccessToken =======> %@", accessToken);
            // 拿到TOKEN后去服务端认证下
            if ([_resp.state isEqualToString:@"get_access_token_bind"]) {
                [WxSdkPlugin wxBindCode:accessToken];
            }else{
                // 拿到TOKEN后去服务端认证下
                [WxSdkPlugin sendLoginAuth:accessToken
                                    result:^(BaseModel *model)
                {
                    [self onWxLoginResp:model code:accessToken];
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
        // 登录
        [NimSdkUtilPlugin doLogin:model.data];
        
    }else if ([model.error isEqualToString:@"1"]){
        [UIViewController hideHUD];
        // 显示绑定手机页面
        NSDictionary* data = model.data;
        if (data != nil) {
            NSString *union_id  = [data objectForKey:@"union_id"];
            NSString *headimg   = [data objectForKey:@"head_img"];
            NSString *nick_name = [data objectForKey:@"nick_name"];
            
            [FlutterBoostPlugin open:@"phone_bind" urlParams:@{
                @"union_id": union_id?:[NSNull null],
                @"headimg": headimg?:[NSNull null],
                @"nick_name": nick_name?:[NSNull null],
                @"code": code?:[NSNull null]
            } exts:@{@"animated": @(YES)} onPageFinished:^(NSDictionary *d) {
                
            } completion:^(BOOL success) {
                
            }];
        }
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

+ (void)wxBindCode:(NSString *)code
{
    NSString *url =  [NSString stringWithFormat:@"%@/g2/user/wx/bind",kBaseUrl];
    NSString *accid = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NSDictionary *params = @{@"accid":accid ? : @"",
                             @"code":code ? : @"",
                             @"union_id":@"",
                             @"app_key":@"wx0f56e7c5e6daa01a"};
    [UIViewController showWaiting];
    
    co_launch(^{
        BaseModel *model = await([HttpHelper post:url params:params]);
        
        [UIViewController hideHUD];
        if(co_getError()) {
            [UIViewController showError:CJ_net_err_msg];
        }else if(model.success) {
            [UIViewController showSuccess:@"绑定成功"];
        }else {
            [UIViewController showError:model.errmsg];
        }
    });
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
    
    co_launch(^{
        BaseModel *model = await([HttpHelper post:kWechatLoginUrl params:params]);
        
        [UIViewController hideHUD];
        if(co_getError()) {
            [UIViewController showError:CJ_net_err_msg];
        }else if(result) {
            result(model);
        }
    });
}

/// 查询微信绑定状态
+ (void)wxBindStatus:(NSDictionary *)params
{
    FlutterResult result = params[wxSDKResultKey];
    NSString *url =  [NSString stringWithFormat:@"%@/g2/user/wx/bind/exist",kBaseUrl];
    NSString *accid = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NSDictionary *p = @{@"accid":accid ? : @"",
                         @"app_key":@"wx0f56e7c5e6daa01a"};
    
    co_launch(^{
        BaseModel *model = await([HttpHelper post:url params:p]);
        
        if(co_getError()) {
            result(@(NO));
            [UIViewController showError:CJ_net_err_msg];
        }else {
            if (model.success && !cj_nil_object(model.data)) {
                result(@(YES));
            }else{
                result(@(NO));
            }
        }
    });
}

/// 解绑微信
+ (void)unBindWeChat:(NSDictionary *)params
{
    FlutterResult result = params[wxSDKResultKey];
    NSString *url =  [NSString stringWithFormat:@"%@/g2/user/wx/untying",kBaseUrl];
    NSString *accid = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NSDictionary *p = @{@"accid":accid ? : @"",
                             @"app_key":@"wx0f56e7c5e6daa01a"};
    
    co_launch(^{
        BaseModel *model = await([HttpHelper post:url params:p]);
        if(co_getError()) {
            result(@(NO));
            [UIViewController showError:CJ_net_err_msg];
        }else {
            if (model.success) {
                result(@(YES));
                [UIViewController showSuccess:@"解绑成功"];
            }else{
                result(@(NO));
                [UIViewController showError:model.errmsg];
            }
        }
    });
}

@end
