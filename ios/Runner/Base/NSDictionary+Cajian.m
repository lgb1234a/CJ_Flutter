//
//  NSDictionary+Cajian.m
//  Runner
//
//  Created by chenyn on 2019/7/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "NSDictionary+Cajian.h"

@implementation NSDictionary (Cajian)

+ (NSDictionary *)cj_dictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        ZZLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
