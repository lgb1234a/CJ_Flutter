//
//  BaseModle.m
//  LotteryMoreMore
//
//  Created by TF_man on 2018/4/28.
//  Copyright © 2018年 Zonst Inc. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"error":@"errno",
             @"switch_1": @"switch"
             };
}


@end
