//
//  NSString+Cajian.m
//  Runner
//
//  Created by chenyn on 2019/8/7.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NSString+Cajian.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Cajian)

- (NSString *)urlDecodedString
{
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)MD5String
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


- (id)jsonStringToDictionaryOrArray
{
    //1.将字符串转换NSData类型
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return nil;
    }
    return dict;
}

+ (NSString *)dictionaryOrArrayToJson:(id)params
{
    
    if (!params)return @"";
    //1.将参数转换成NSData类型
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        return @"";
    }
    //2.将NSData类型转换成NSSting类型
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //3.去掉字符串中的空格和换行符
    NSMutableString *mutJsonStr = [NSMutableString stringWithString:jsonString];
    NSRange rangeSpace = {0,mutJsonStr.length};
    [mutJsonStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:rangeSpace];
    NSRange rangeWrap = {0,mutJsonStr.length};
    [mutJsonStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:rangeWrap];
    mutJsonStr = [mutJsonStr stringByReplacingOccurrencesOfString:@"\\" withString:@""].mutableCopy;
    return mutJsonStr;
}

@end
