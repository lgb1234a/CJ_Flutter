//
//  CJViewController.h
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJViewController : FlutterViewController

/**
 初始化一个flutter 页面，以FlutterVC为容器

 \\******
 需要的JSON字符串格式如下
 {
 'route':'login',
 'channel_name':'com.zqtd.cajian/login',
 'params':{
    'team_id':'298ssdj9238'
    }
 }
 *******\\
 @param openUrl 页面初始化路由和参数
 
 @return 返回VC
 */
- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl;

@end

NS_ASSUME_NONNULL_END
