//
//  BaseModle.h
//  LotteryMoreMore
//
//  Created by TF_man on 2018/4/28.
//  Copyright © 2018年 Zonst Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

@property (nonatomic,copy)NSString *errmsg;

@property (nonatomic,copy)NSString *error;

@property (nonatomic, assign) NSInteger errorNo;

// [model.error isEqualToString:@"0"]
@property (nonatomic, assign) BOOL success;

@property (nonatomic,strong) id data;

@property (nonatomic, assign) NSInteger total;

// 获取新版本接口 扩充字段
@property (nonatomic,copy)NSString *low_version;

@property (nonatomic,copy)NSString *switch_1;
@property (nonatomic,copy)NSString *version;
@property (nonatomic,assign)BOOL show_invite;

@end
