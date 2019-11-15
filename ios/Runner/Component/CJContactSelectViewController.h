//
//  CJContactSelectViewController.h
//  Runner
//
//  Created by chenyn on 2019/9/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMContactSelectConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJContactSelectViewController : UIViewController

@property (nonatomic, copy) void (^finished)(NSArray *ids);

/**
 *  初始化方法
 *
 *  @param config 联系人选择器配置
 *
 *  @return 选择器
 */
- (instancetype)initWithConfig:(id<NIMContactSelectConfig>)config;

@end

NS_ASSUME_NONNULL_END
