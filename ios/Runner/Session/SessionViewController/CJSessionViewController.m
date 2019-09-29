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

@interface CJSessionViewController ()

@property (nonatomic,strong) CJMoreContainerConfig *sessionConfig;

@end

@implementation CJSessionViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 配置导航条按钮 */
    [self setUpNavBarItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCJUpdateMessageNotification:)
                                                 name:CJUpdateMessageNotification
                                               object:nil];
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
    // TODO:跳转flutter 聊天信息页
    
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
