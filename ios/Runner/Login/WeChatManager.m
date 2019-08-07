#import "WeChatManager.h"
#import "WXApi.h"
#import "WXApiObject.h"

@implementation WeChatManager

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
