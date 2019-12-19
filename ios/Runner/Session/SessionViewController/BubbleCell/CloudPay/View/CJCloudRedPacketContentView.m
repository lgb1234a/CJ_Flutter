//
//  CJCloudRedPacketContentView.m
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJCloudRedPacketContentView.h"
#import "CJCloudRedPacketAttachment.h"

@interface CJCloudRedPacketContentView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) CJCloudRedPacketAttachment *attachment;

@end

@implementation CJCloudRedPacketContentView

// 初始化UI
- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        // 内容布局
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:13.f];
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont systemFontOfSize:13.f];
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:16.f];
        
        [self addSubview:_titleLabel];
        [self addSubview:_subTitleLabel];
        [self addSubview:_descLabel];
        
    }
    return self;
}

// 点击事件
- (void)onTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onCatchEvent:)]) {
        NIMKitEvent *event = [[NIMKitEvent alloc] init];
        event.messageModel = self.model;
        event.data = self;
        [self.delegate onCatchEvent:event];
    }
}

// 刷新数据
- (void)refresh:(NIMMessageModel*)data{
    [super refresh:data];
    
    NIMCustomObject *object = (NIMCustomObject *)data.message.messageObject;
    _attachment = (CJCloudRedPacketAttachment *)object.attachment;
    
    self.titleLabel.text = _attachment.title;
    self.descLabel.text  = _attachment.content;
    
    self.titleLabel.textColor    =  [UIColor lightGrayColor];
    self.subTitleLabel.textColor =  [UIColor whiteColor];
    self.descLabel.textColor     =  [UIColor whiteColor];
    
    [self.titleLabel sizeToFit];
    CGRect rect = self.titleLabel.frame;
    if (CGRectGetMaxX(rect) > self.bounds.size.width)
    {
        rect.size.width = self.bounds.size.width - rect.origin.x - 20;
        self.titleLabel.frame = rect;
    }
    if (_attachment.status == CloudRedPacketStatusGot) {
        self.subTitleLabel.text = @"已被领取";
    }
    else if (_attachment.status == CloudRedPacketStatusNull)
    {
        self.subTitleLabel.text = @"已被领取";
    }
    else if(_attachment.status == CloudRedPacketStatusDue)
    {
        self.subTitleLabel.text = @"红包已过期";
    }
    else
        self.subTitleLabel.text = self.model.message.isOutgoingMsg? @"查看红包" : @"领取红包";
    [self.bubbleImageView setImage:[self chatBubbleImageForState:UIControlStateNormal outgoing:data.message.isOutgoingMsg]];
    [self.bubbleImageView setHighlightedImage:[self chatBubbleImageForState:UIControlStateHighlighted outgoing:data.message.isOutgoingMsg]];
}

// 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL outgoing = self.model.message.isOutgoingMsg;
    if (outgoing)
    {
        CGFloat descX = 50.f;
        CGFloat descY = 11.f;
        CGFloat descW = self.frame.size.width - self.descLabel.frame.origin.x - 10;
        CGFloat descH = 24.f;
        self.descLabel.frame = CGRectMake(descX, descY, descW, descH);
        
        CGFloat sTitleX = 50.f;
        CGFloat sTitleY = CGRectGetMaxY(self.descLabel.frame);
        CGFloat sTitleW = self.frame.size.width - self.subTitleLabel.frame.origin.x - 10;
        CGFloat sTitleH = 20.f;
        self.subTitleLabel.frame = CGRectMake(sTitleX, sTitleY, sTitleW, sTitleH);
        
        
        CGFloat titleX = 14.f;
        CGFloat titleY = self.frame.size.height - 23.f;
        CGFloat titleW = self.frame.size.width - self.titleLabel.frame.origin.x - 10;
        CGFloat titleH = 21.f;
        
        self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    }
    else
    {
        CGFloat descX = 55.f;
        CGFloat descY = 11.f;
        CGFloat descW = self.frame.size.width - self.descLabel.frame.origin.x - 10;
        CGFloat descH = 24.f;
        self.descLabel.frame = CGRectMake(descX, descY, descW, descH);
        
        
        CGFloat sTitleX = 55.f;
        CGFloat sTitleY = CGRectGetMaxY(self.descLabel.frame);
        CGFloat sTitleW = self.frame.size.width - self.subTitleLabel.frame.origin.x - 10;
        CGFloat sTitleH = 20.f;
        self.subTitleLabel.frame = CGRectMake(sTitleX, sTitleY, sTitleW, sTitleH);
        
        CGFloat titleX = 14.f;
        CGFloat titleY = self.frame.size.height - 23.f;
        CGFloat titleW = self.frame.size.width - self.titleLabel.frame.origin.x - 10;
        CGFloat titleH = 21.f;
        self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    }
}

// 消息气泡背景图
- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
{
    NSString *stateString = state == UIControlStateNormal? @"normal" : @"pressed";
    if (_attachment && _attachment.status != CloudRedPacketStatusNormal &&  state == UIControlStateNormal) {
        stateString = @"get";
    }
    NSString *imageName = @"icon_mfRedpacket_";
    if (outgoing)
    {
        imageName = [imageName stringByAppendingString:@"from_"];
    }
    else
    {
        imageName = [imageName stringByAppendingString:@"to_"];
    }
    imageName = [imageName stringByAppendingString:stateString];
    return [UIImage imageNamed:imageName];
}

@end
