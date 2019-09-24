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
#import "CJPayManager.h"
#import "CJCustomAttachmentDefines.h"

@interface CJSessionViewController ()

@property (nonatomic,strong) CJMoreContainerConfig *sessionConfig;

@end

@implementation CJSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 配置导航条按钮 */
    [self setUpNavBarItem];
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
- (void)onTapMediaItemCajianRP:(NIMMediaItem *)item
{
    // TODO: 擦肩红包  CJPayManager
    
}

- (void)onTapMediaItemCloudRedPacket:(NIMMediaItem *)item
{
    // TODO:云红包  CJPayManager
}

- (void)onTapMediaItemYeePacket:(NIMMediaItem *)item
{
    // TODO:易红包  CJPayManager
}

- (void)onTapMediaItemYXTransfer:(NIMMediaItem *)item
{
    // TODO:易转账  CJPayManager
}

- (void)onTapMediaItemProfileCard:(NIMMediaItem *)item
{
    // TODO:名片
}

- (void)onTapMediaItemAliPayCode:(NIMMediaItem *)item
{
    // TODO:收款码
}

- (void)onTapMediaItemPersonalstamp:(NIMMediaItem *)item
{
    // TODO:抖一抖
}

- (void)onTapMediaItemTeamNotice:(NIMMediaItem *)item
{
    // TODO:群通知
}

- (void)onTapMediaItemCollection:(NIMMediaItem *)item
{
    // TODO:发收藏
}

- (void)onTapMediaItemLocation:(NIMMediaItem *)item
{
    // TODO:发定位
}

#pragma mark - private
- (void)enterSessionInfoPage:(id)sender
{
    // TODO:跳转flutter 聊天信息页
    
}

@end
