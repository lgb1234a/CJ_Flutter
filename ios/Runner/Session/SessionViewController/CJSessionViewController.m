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
    
    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        self.navigationItem.rightBarButtonItems  = @[enterTeamCardItem];
    }
}


#pragma mark - NIMMeidaButton
- (void)onTapMediaItemCajianRP:(NIMMediaItem *)item
{
    // TODO: 擦肩红包
    
}

- (void)onTapMediaItemCloudRedPacket:(NIMMediaItem *)item
{
    // TODO:云红包
}

- (void)onTapMediaItemYeePacket:(NIMMediaItem *)item
{
    // TODO:易红包
}

- (void)onTapMediaItemYXTransfer:(NIMMediaItem *)item
{
    // TODO:易转账
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
