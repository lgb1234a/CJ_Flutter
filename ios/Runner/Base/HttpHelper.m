//
//  HttpHelper.m
//  CaJian
//
//  Created by Apple on 2018/11/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "HttpHelper.h"
#import <AFNetworking.h>
#import <NIMSDK/NIMSDK.h>
#import "BaseModel.h"
#import "sys/utsname.h"
#import "Reachability.h"
#import "HttpConstant.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

// 字符串拼接函数
NSString *stringAppding(NSString *baseString, ...) {
    NSMutableString *mutStr = baseString.mutableCopy;
    va_list args;
    NSString *arg;
    va_start(args, baseString);
    while ((arg = va_arg(args, NSString *))) {
        [mutStr appendString:arg];
    }
    va_end(args);
    return mutStr.copy;
}

/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
NSString * YXPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

// 键值对象 参见AFQueryStringPair
@interface YXQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation YXQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return YXPercentEscapedStringFromString([self.field description]);
    } else {
        NSString *key = YXPercentEscapedStringFromString([self.field description]);
        key = [key lowercaseString];
        return [NSString stringWithFormat:@"%@=%@", key, YXPercentEscapedStringFromString([self.value description])];
    }
}

@end

@interface HttpHelper ()

@property (nonatomic, strong) NSMutableDictionary *requestDict;
@property (nonatomic, strong) AFURLSessionManager *manager;
@property (nonatomic, strong) AFHTTPSessionManager *httpSession;

@end

@implementation HttpHelper

// 构造query
NSString * YXQueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (YXQueryStringPair *pair in YXQueryStringPairsFromDictionary(parameters)) {
        if(!pair.value || [pair.value isEqual:[NSNull null]]) {
            continue;
        }else if ([pair.value isKindOfClass:NSString.class]) {
            NSString *pairValue = pair.value;
            if(pairValue.length == 0) {
                continue;
            }
        }
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * YXQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return YXQueryStringPairsFromKeyAndValue(nil, dictionary);
}

// 拆分容器，组装键值对象pair
NSArray * YXQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:YXQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        
        NSString *arr_str = [NSString dictionaryOrArrayToJson:value];
        [mutableQueryStringComponents addObject:[[YXQueryStringPair alloc] initWithField:key value:arr_str]];
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:YXQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[YXQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

// 注册接口签名不一致
static inline NSString *signForUrlString(NSString *urlStr)
{
    if([urlStr isEqualToString:kRegisterAppUrl])
    {
        return @"e72557eeab0e2ae82eabaf91ecef8315";
    }
    
    return @"74d6de00551d4db6a2a3e4484ba101ae";
}

// 单例
+ (instancetype)sharedHelper
{
    static HttpHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[super allocWithZone:NULL] init];
    });
    
    return helper;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [HttpHelper sharedHelper];
}


- (void)postWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(void (^)(BaseModel *model))success
            failure:(void (^)(NSError *error))failure
{
    NSString *query = YXQueryStringFromParameters(params);
    NSString *requestKey = stringAppding(url, query, nil);
    
    if([self.requestDict valueForKey:requestKey]) {
        // 过滤重复请求
        return;
    }
    NSData *body;
    if (params) {
        NSError *error = nil;
        body = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        ZZLog(@"%@", error);
    }
    NSString *requestUrl = url;
    
    if(!self.manager) {
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:requestUrl parameters:nil error:nil];
    request.timeoutInterval = 20;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    [HttpHelper configRequestPlatform:request];
    NSString *sign = [HttpHelper sign:signForUrlString(url) withParams:params];
    [request setValue:sign forHTTPHeaderField:@"sign"];
    NSString *accid = [NIMSDK sharedSDK].loginManager.currentAccount;
    [request setValue:accid forHTTPHeaderField:@"accid"];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                 @"text/html",
                                                 @"text/json",
                                                 @"text/javascript",
                                                 @"text/plain",
                                                 nil];
    self.manager.responseSerializer = responseSerializer;
    
    ZZLog(@"请求的URL：%@,参数为%@,请求的头为%@",requestUrl,params,request.allHTTPHeaderFields);
    
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        @synchronized (self.requestDict) {
            [self.requestDict removeObjectForKey:requestKey];
        }
        
        if (!error) {
            NSString *jsonstring=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            ZZLog(@"json:%@",jsonstring);
            if (jsonstring) {
                NSDictionary *dic = [jsonstring jsonStringToDictionaryOrArray];
                BaseModel *model = [BaseModel yy_modelWithJSON:dic];
                if([model.error isEqualToString:@"0"])
                {
                    model.success = YES;
                    model.errorNo = 0;
                    success(model);
                    return;
                }
                
                model.success = NO;
                model.errorNo = [model.error integerValue];
                success(model);
                return;
            }
            
            NSError *err = [NSError errorWithDomain:@"com.zonst.cajian.ErrorDomain"
                                               code:-101
                                           userInfo:@{
                                                      NSLocalizedDescriptionKey: @"无法解析JSON"
                                                      }];
            [UIViewController showMessage:@"返回的数据格式错误，请联系客服!" afterDelay:1];
            failure(err);
        } else {
            if (error){
                NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                NSString *errorsStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                ZZLog(@"解析失败--%@---%@",url,errorsStr);
            }
            [UIViewController showMessage:@"网络开小差了~" afterDelay:1];
            failure(error);
        }
    }];
    
    @synchronized (self.requestDict) {
        [self.requestDict tn_setObject:task forKey:requestKey];
    }
    [task resume];
}

+ (void)postWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(void (^)(BaseModel *model))success
            failure:(void (^)(NSError *error))failure{
    
    [[HttpHelper sharedHelper] postWithURL:url params:params success:success failure:failure];
}

- (void)getWithURL:(NSString *)url
            params:(NSDictionary *)params
           success:(void (^)(id))success
           failure:(void (^)(NSError *))failure{
    
    NSString *query = YXQueryStringFromParameters(params);
    NSString *requestKey = stringAppding(url, query, nil);
    if([self.requestDict valueForKey:requestKey]) {
        // 过滤重复请求
        return;
    }
    
    if(!self.httpSession) {
        // 1.创建请求管理对象
        self.httpSession = [AFHTTPSessionManager manager];
        self.httpSession.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.httpSession.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
   
    // 2.发送请求
    NSURLSessionDataTask *task = [self.httpSession GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        @synchronized (self.requestDict) {
            [self.requestDict removeObjectForKey:requestKey];
        }
        
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        @synchronized (self.requestDict) {
            [self.requestDict removeObjectForKey:requestKey];
        }
        
        if (failure) {
            failure(error);
        }
    }];
    
    @synchronized (self.requestDict) {
        [self.requestDict tn_setObject:task forKey:requestKey];
    }
}

+ (void)getWithURL:(NSString *)url
            params:(NSDictionary *)params
           success:(void (^)(id))success
           failure:(void (^)(NSError *))failure
{
    [[HttpHelper sharedHelper] getWithURL:url params:params success:success failure:failure];
}

- (void)postInforTopImgWithUrl:(NSString *)url
                        parame:(NSDictionary *)params
                          path:(NSString *)path
                       success:(void (^)(id json))success
                       failure:(void (^)(NSError *error))failure{
    
    if(!self.httpSession) {
        self.httpSession = [AFHTTPSessionManager manager];
        self.httpSession.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.httpSession.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    NSString *sign = [HttpHelper sign:signForUrlString(url) withParams:params];
    [self.httpSession.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
    
    [self.httpSession POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" fileName:@"image.jpg" mimeType:@"image.png" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)postInforTopImgWithUrl:(NSString *)url
                        parame:(NSDictionary *)params
                          path:(NSString *)path
                       success:(void (^)(id json))success
                       failure:(void (^)(NSError *error))failure
{
    [[HttpHelper sharedHelper] postInforTopImgWithUrl:url parame:params path:path success:success failure:failure];
}


+ (void)configRequestPlatform:(NSMutableURLRequest *)request
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"] ? : @"";
    NSString *accid_str = [[[NIMSDK sharedSDK] loginManager] currentAccount] ? : @"";
    
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *model_str = deviceString;
    NSString *net_str = [self getNetworkStatus];
    NSString *screen_str = [self getScreenResolution];
    NSString *osv_str = [self getSystemVersion];
    NSString *platform_str = [NSString stringWithFormat:@"{\"accid\":\"%@\",\"model\":\"%@\",\"os\":\"ios\",\"version\":\"%@\",\"net\":\"%@\",\"screen\":\"%@\",\"osv\":\"%@\"}",accid_str,model_str,app_Version ,net_str,screen_str,osv_str];
    [request setValue:platform_str forHTTPHeaderField:@"platform"];
}

// 参数加签
+ (NSString *)sign:(NSString *)solt withParams:(NSDictionary *)params
{
    NSString *soltKeyValueStr = [NSString stringWithFormat:@"%@=%@",@"solt", solt];
    if (params) {
        NSString *query = stringAppding(YXQueryStringFromParameters(params), @"&",soltKeyValueStr, nil);
        query = [query urlDecodedString];
        ZZLog(@"签名：%@， MD5值：%@", query, [query MD5String]);
        return [query MD5String] ? : @"";
    }else{
        return [soltKeyValueStr MD5String] ? : @"";
    }
}

//获取网络状态
+ (NSString *)getNetworkStatus{
    
    //可以使用多种方式初始化
    Reachability *reach=[Reachability reachabilityWithHostName:@"www.baidu.com"];
    //2.判断当前的网络状态
    switch([reach currentReachabilityStatus]){
        case ReachableViaWWAN://手机自带网络
            return [self telephonyNetwork];
        case ReachableViaWiFi://WIFI
            return @"wifi";
        default:
            return @"未知";
    }
}

//返回3G、2G、4G 网络状态
+ (NSString *)telephonyNetwork{
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = info.currentRadioAccessTechnology;
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]) {//2G
        return @"2G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]||[currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]||[currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]||[currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]) {//3G
        return @"3G";
    }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){//4G
        return @"4G";
    }else{//未知网络状态
        return @"未知";
    }
}

//屏幕的分辨率
+ (NSString *)getScreenResolution{
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    CGFloat width = rect.size.width*scale_screen;
    CGFloat height = rect.size.height*scale_screen;
    return [NSString stringWithFormat:@"%@*%@",@(height),@(width)];
}

//获取操作系统的版本号
+ (NSString *)getSystemVersion{
    return [[UIDevice currentDevice] systemVersion];
}

@end
