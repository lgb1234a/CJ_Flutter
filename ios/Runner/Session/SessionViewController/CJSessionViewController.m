//
//  CJSessionViewController.m
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJSessionViewController.h"
#import "NIMInputMoreContainerView.h"
#import "CJMoreContainerConfig.h"
#import "CJCustomAttachmentDefines.h"
#import <NIMMessageMaker.h>

@interface CJSessionViewController ()

@property (nonatomic,strong) CJMoreContainerConfig *sessionConfig;

@end

@implementation CJSessionViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// flutter boost 协议
- (instancetype)initWithBoostParams:(NSDictionary *)boost_params
{
    NIMSession *session = [NIMSession session:boost_params[@"id"]
                   type:[boost_params[@"type"] integerValue]];
    self = [super initWithSession:session];
    if(self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /* 配置导航条按钮 */
    [self setUpNavBarItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCJUpdateMessageNotification:)
                                                 name:CJUpdateMessageNotification
                                               object:nil];
    
    /// 处理分享数据
    [self handleShareData];
}

- (void)handleShareData
{
    if(self.shareModel) {
        if(self.shareModel.type == CajianShareTypeImage) {
            CJShareImageModel *imgModel = (CJShareImageModel *)self.shareModel;
            co_launch(^{
                UIImage *shareImage = await([UIImage async_imageWithData:imgModel.imageData]);
                [self sendMessage:[NIMMessageMaker msgWithImage:shareImage]];
            });
        }
        
        // 备注
        if(!cj_empty_string(self.shareModel.leaveMessage)) {
            [self sendMessage:[NIMMessageMaker msgWithText:self.shareModel.leaveMessage]];
        }
        self.shareModel = nil;
    }
}

/* 重新修改session配置 */
- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[CJMoreContainerConfig alloc] init];
        _sessionConfig.session = self.session;
    }
    return _sessionConfig;
}

- (void)setUpNavBarItem
{
    UIButton *enterTeamCard = [UIButton buttonWithType:UIButtonTypeCustom];
    [enterTeamCard addTarget:self action:@selector(enterSessionInfoPage:) forControlEvents:UIControlEventTouchUpInside];
    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
    [enterTeamCard sizeToFit];
    
    UIBarButtonItem *enterTeamCardItem = [[UIBarButtonItem alloc] initWithCustomView:enterTeamCard];
    
    self.navigationItem.rightBarButtonItems  = @[enterTeamCardItem];
}

#pragma mark - override
- (BOOL)onTapCell:(NIMKitEvent *)event
{
    BOOL handle = NO;
    if([event.messageModel.message.messageObject isKindOfClass:NIMCustomObject.class])
    {
        // 自定义消息事件分发
        NIMCustomObject *object = (NIMCustomObject *)event.messageModel.message.messageObject;
        id<CJCustomAttachment> attachment = (id<CJCustomAttachment>)object.attachment;
        if([attachment respondsToSelector:@selector(handleTapCellEvent:onSession:)])
        {
            [attachment handleTapCellEvent:event onSession:self];
        }
    }else {
        handle = [super onTapCell:event];
    }
    
    return handle;
}


#pragma mark - NIMMeidaButton
- (BOOL)onTapMediaItem:(NIMMediaItem *)item
{
    BOOL handled = NO;
    SEL sel = item.selctor;
    
    // 将代理方法抽离到CJMoreContainerConfig 配置类中
    handled = sel && [CJMoreContainerConfig respondsToSelector:sel];
    if (handled) {
        [CJMoreContainerConfig performSelector:sel withObject:item withObject:self];
        handled = YES;
    }else if(sel && [super respondsToSelector:sel])
    {
        CJ_SuppressPerformSelectorLeakWarning([super performSelector:sel withObject:item]);
        handled = YES;
    }
    return handled;
}

#pragma mark - private
- (void)enterSessionInfoPage:(id)sender
{
    [FlutterBoostPlugin open:@"session_info"
                   urlParams:@{@"id": self.session.sessionId, @"type": @(self.session.sessionType)}
                        exts:@{@"animated": @(YES)}
              onPageFinished:^(NSDictionary *result) {}
                  completion:nil];
}

// 刷新消息
- (void)onCJUpdateMessageNotification:(NSNotification *)n
{
    id  object = n.object;
    if (object != nil && [object isKindOfClass:[NIMMessage class]]) {
        NIMMessage* message = (NIMMessage*)object;
        if (message) {
            // 更新消息内容
            [self uiUpdateMessage:message];
        }
    }
}


@end
