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


#pragma mark - NIMMeidaButton
- (void)onTapMediaItemCajianRP:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemCloudRedPacket:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemYeePacket:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemYXTransfer:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemProfileCard:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemAliPayCode:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemPersonalstamp:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemTeamNotice:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemCollection:(NIMMediaItem *)item
{
    
}

- (void)onTapMediaItemLocation:(NIMMediaItem *)item
{
    
}

@end
