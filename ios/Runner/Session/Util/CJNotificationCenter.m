//
//  CJNotificationCenter.m
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJNotificationCenter.h"
#import "NTESAVNotifier.h"
#import "NTESSessionUtil.h"
#import <AVFoundation/AVFoundation.h>
#include "AppDelegate.h"

NSString *NTESCustomNotificationCountChanged = @"NTESCustomNotificationCountChanged";

@interface CJNotificationCenter ()
<NIMSystemNotificationManagerDelegate,
NIMBroadcastManager,
NIMSignalManager,
NIMChatManagerDelegate>

@property (nonatomic,strong) AVAudioPlayer *player; //播放提示音
@property (nonatomic,strong) NTESAVNotifier *notifier;

@end

@implementation CJNotificationCenter

+ (instancetype)sharedCenter
{
    static CJNotificationCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CJNotificationCenter alloc] init];
    });
    return instance;
}

- (void)start
{
    
}

- (instancetype)init {
    self = [super init];
    if(self) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"message" withExtension:@"wav"];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _notifier = [[NTESAVNotifier alloc] init];
        
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
        [[NIMSDK sharedSDK].broadcastManager addDelegate:self];
        [[NIMSDK sharedSDK].signalManager addDelegate:self];
    }
    return self;
}


- (void)dealloc{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[NIMSDK sharedSDK].broadcastManager removeDelegate:self];
    [[NIMSDK sharedSDK].signalManager removeDelegate:self];
}

#pragma mark - NIMChatManagerDelegate
- (void)onRecvMessages:(NSArray *)recvMessages
{
    NSArray *messages = [self filterMessages:recvMessages];
    if (messages.count)
    {
        static BOOL isPlaying = NO;
        if (isPlaying) {
            return;
        }
        isPlaying = YES;
        [self playMessageAudioTip];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPlaying = NO;
        });
        [self checkMessageAt:messages];
    }
}

- (void)playMessageAudioTip
{
    UITabBarController *tb = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbar;
    UINavigationController *nav = tb.selectedViewController;
    BOOL needPlay = YES;
    for (UIViewController *vc in nav.viewControllers) {
        if ([vc isKindOfClass:[NIMSessionViewController class]])
        {
            needPlay = NO;
            break;
        }
    }
    if (needPlay) {
        [self.player stop];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error:nil];
        [self.player play];
    }
}

- (void)checkMessageAt:(NSArray<NIMMessage *> *)messages
{
    //一定是同个 session 的消息
    NIMSession *session = [messages.firstObject session];
    if ([self.currentSessionViewController.session isEqual:session])
    {
        //只有在@所属会话页外面才需要标记有人@你
        return;
    }
    
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    
    for (NIMMessage *message in messages) {
        if ([message.apnsMemberOption.userIds containsObject:me]) {
            [NTESSessionUtil addRecentSessionMark:session type:NTESRecentSessionMarkTypeAt];
            return;
        }
    }
}

- (NSArray *)filterMessages:(NSArray *)messages
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NIMMessage *message in messages)
    {
//        if ([self checkRedPacketTip:message] && ![self canSaveMessageRedPacketTip:message])
//        {
//            [[NIMSDK  sharedSDK].conversationManager deleteMessage:message];
//            [self.currentSessionViewController uiDeleteMessage:message];
//            continue;
//        }
        [array addObject:message];
    }
    return [NSArray arrayWithArray:array];
}

//- (void)onRecvRevokeMessageNotification:(NIMRevokeMessageNotification *)notification
//{
//    NIMMessage *tipMessage = [NTESSessionMsgConverter msgWithTip:[NTESSessionUtil tipOnMessageRevoked:notification]];
//    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
//    setting.shouldBeCounted = NO;
//    tipMessage.setting = setting;
//    tipMessage.timestamp = notification.timestamp;
//
//    NTESMainTabController *tabVC = [NTESMainTabController instance];
//    UINavigationController *nav = tabVC.selectedViewController;
//
//    for (NTESSessionViewController *vc in nav.viewControllers) {
//        if ([vc isKindOfClass:[NTESSessionViewController class]]
//            && [vc.session.sessionId isEqualToString:notification.session.sessionId]) {
//            NIMMessageModel *model = [vc uiDeleteMessage:notification.message];
//            if (model) {
//                [vc uiInsertMessages:@[tipMessage]];
//            }
//            break;
//        }
//    }
//
//    // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
//    [[NIMSDK sharedSDK].conversationManager saveMessage:tipMessage
//                                             forSession:notification.session
//                                             completion:nil];
//}


#pragma mark - NIMSystemNotificationManagerDelegate
//- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification{
//
//    NSString *content = notification.content;
//    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
//    if (data)
//    {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
//                                                             options:0
//                                                               error:nil];
//        if ([dict isKindOfClass:[NSDictionary class]])
//        {
//            switch ([dict jsonInteger:NTESNotifyID]) {
//                case NTESCustom:{
//                    //SDK并不会存储自定义的系统通知，需要上层结合业务逻辑考虑是否做存储。这里给出一个存储的例子。
//                    NTESCustomNotificationObject *object = [[NTESCustomNotificationObject alloc] initWithNotification:notification];
//                    //这里只负责存储可离线的自定义通知，推荐上层应用也这么处理，需要持久化的通知都走可离线通知
//                    if (!notification.sendToOnlineUsersOnly) {
//                        [[NTESCustomNotificationDB sharedInstance] saveNotification:object];
//                    }
//                    if (notification.setting.shouldBeCounted) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:NTESCustomNotificationCountChanged object:nil];
//                    }
//                    NSString *content  = [dict jsonString:NTESCustomContent];
//                    [self makeToast:content];
//                }
//                    break;
//                case NTESTeamMeetingCall:{
//                    if (![self shouldResponseBusy]) {
//                        //繁忙的话，不回复任何信息，直接丢掉，让呼叫方直接走超时
//                        NSTimeInterval sendTime = notification.timestamp;
//                        NSTimeInterval nowTime  = [[NSDate date] timeIntervalSince1970];
//                        if (nowTime - sendTime < 45)
//                        {
//                            //60 秒内，认为有效，否则丢弃
//                            NTESTeamMeetingCalleeInfo *info = [[NTESTeamMeetingCalleeInfo alloc] init];
//                            info.teamId  = [dict jsonString:NTESTeamMeetingTeamId];
//                            info.members = [dict jsonArray:NTESTeamMeetingMembers];
//                            info.meetingName = [dict jsonString:NTESTeamMeetingName];
//                            info.teamName = [dict jsonString:NTESTeamMeetingTeamName];
//
//                            NTESTeamMeetingCallingViewController *vc = [[NTESTeamMeetingCallingViewController alloc] initWithCalleeInfo:info];
//                            [self presentModelViewController:vc];
//                        }
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
//}

#pragma mark - NIMBroadcastManagerDelegate
- (void)onReceiveBroadcastMessage:(NIMBroadcastMessage *)broadcastMessage
{
    [self makeToast:broadcastMessage.content];
}


#pragma mark - private
- (NIMSessionViewController *)currentSessionViewController
{
    UITabBarController *tb = ((AppDelegate *)[UIApplication sharedApplication].delegate).tabbar;
    UINavigationController *nav = tb.selectedViewController;
    for (UIViewController *vc in nav.viewControllers)
    {
        if ([vc isKindOfClass:[NIMSessionViewController class]])
        {
            return (NIMSessionViewController *)vc;
        }
    }
    return nil;
}

- (void)makeToast:(NSString *)content
{
    [UIViewController showMessage:content afterDelay:0];
}

@end
