//
//  CJNewFriendViewController.m
//  Runner
//
//  Created by chenyn on 2019/12/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNewFriendViewController.h"

@interface CJNewFriendViewController ()<NIMSystemNotificationManagerDelegate, CJBoostViewController>

@property (nonatomic, copy) NSArray<NIMSystemNotification *> *notifications;

@end

@implementation CJNewFriendViewController

- (instancetype)initWithBoostParams:(NSDictionary *)boost_params
{
    self = [super init];
    if (self) {
        [self setName:@"new_friend"];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _notifications = [[NIMSDK sharedSDK].systemNotificationManager fetchSystemNotifications:nil limit:MAXFLOAT];
    
    __weak typeof(self) wself = self;
    [[FlutterBoostPlugin sharedInstance] addEventListener:^(NSString *name, NSDictionary *arguments) {
        long notificationID = [arguments[@"notificationId"] longLongValue];
        int handleStatus = [arguments[@"handleStatus"] intValue];
        
        NSArray *filter_notis = [wself.notifications cj_filter:^BOOL(NIMSystemNotification *notification) {
            return notification.notificationId == notificationID;
        }];
        
        NIMSystemNotification *noti = filter_notis.firstObject;
        noti.handleStatus = handleStatus;
    } forName:@"handledNotification"];
}

#pragma mark ---- NIMSystemNotificationManagerDelegate
- (void)onReceiveSystemNotification:(NIMSystemNotification *)notification
{
    [[FlutterBoostPlugin sharedInstance] sendEvent:@"newNotification" arguments:@{
        @"notificationId": @(notification.notificationId),
        @"type": @(notification.type),
        @"timestamp": @(notification.timestamp),
        @"sourceID": notification.sourceID?:[NSNull null],
        @"targetID": notification.targetID?:[NSNull null],
        @"postscript": notification.postscript?:[NSNull null],
        @"read": @(notification.read),
        @"handleStatus": @(notification.handleStatus),
        @"notifyExt": notification.notifyExt?:[NSNull null],
        @"attachment": notification.attachment?:[NSNull null]
    }];
}


@end
