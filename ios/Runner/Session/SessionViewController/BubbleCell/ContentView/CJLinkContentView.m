//
//  CJLinkContentView.m
//  Runner
//
//  Created by chenyn on 2019/12/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJLinkContentView.h"
#import "CJLinkAttachment.h"
#import "NIMAvatarImageView.h"
#import "UIImage+NIMKit.h"

@interface CJLinkContentView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *appNameLabel;

@property (nonatomic, strong) UIView *lineView;


@property (nonatomic, strong) NIMAvatarImageView *iconView;
@property (nonatomic, strong) UIImage *defaulticon;


@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) NIMAvatarImageView *appIconView;

@end

@implementation CJLinkContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        // 内容布局
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:15.f];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor =  Main_TextBlackColor;
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:11.f];
        _contentLabel.numberOfLines = 3;
        _contentLabel.textColor = Main_TextGrayColor;
        
        _appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _appNameLabel.font = [UIFont systemFontOfSize:10.f];
        _appNameLabel.textColor = Main_TextGrayColor;
        
        _iconView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _appIconView = [[NIMAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _defaulticon =   [UIImage imageNamed:@"icon_default_link"];
        _lineView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) ];
        _lineView.backgroundColor = Main_lineColor;
        
        [self addSubview:_titleLabel];
        [self addSubview:_contentLabel];
        [self addSubview:_appNameLabel];
        [self addSubview:_iconView];
        [self addSubview:_appIconView];
        [self addSubview:_lineView];
    }
    return self;
}


- (void)onTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onCatchEvent:)]) {
        NIMKitEvent *event = [[NIMKitEvent alloc] init];
        event.messageModel = self.model;
        event.data = self;
        [self.delegate onCatchEvent:event];
    }
}

#pragma mark - 系统父类方法
- (void)refresh:(NIMMessageModel*)data{
    [super refresh:data];
    
    NIMCustomObject *object = data.message.messageObject;
    CJLinkAttachment *attachment = (CJLinkAttachment *)object.attachment;
    
    self.titleLabel.text = attachment.title;
    if(attachment.extention.length>0 &&[attachment.extention isEqualToString:@"yes"])
    {
        self.contentLabel.text = attachment.webUrl;
        self.iconView.image = _defaulticon;
        self.lineView.hidden = YES;
        self.appNameLabel.hidden = YES;
        self.appIconView.hidden = YES;
    }
    else
    {
        self.lineView.hidden = NO;
        self.appNameLabel.hidden = NO;
        self.appIconView.hidden = NO;
        self.contentLabel.text = attachment.content;
        
        if (attachment.imageData != nil && ![attachment.imageData isEqualToString:@""]) {
            [self.iconView nim_setImageWithURL:[NSURL URLWithString:attachment.imageData] placeholderImage:self.defaulticon options:SDWebImageRetryFailed];
        }
        
        if (attachment.appIcon != nil && ![attachment.appIcon isEqualToString:@""]) {
            [self.appIconView nim_setImageWithURL:[NSURL URLWithString:attachment.appIcon] placeholderImage:self.defaulticon options:SDWebImageRetryFailed];
            
        }
    }
    self.iconView.userInteractionEnabled = NO;
    self.appNameLabel.text =  attachment.appName;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL outgoing = self.model.message.isOutgoingMsg;
    CGFloat iconWidth = 45.f;
    CGFloat appiconW = 10.0f;
    CGFloat cellH = CGRectGetHeight(self.frame);
    CGFloat cellW = CGRectGetWidth(self.frame);
    
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(150.f, 50.f)];
    contentSize = CGSizeMake(MIN(contentSize.width, 150.f), MIN(contentSize.height, 50.f));
    if (outgoing)
    {
        self.titleLabel.frame = CGRectMake(10.0f, 5.f, 210.f, 40.f);
        self.contentLabel.frame = CGRectMake(10.0f, 48.f, contentSize.width, contentSize.height);
        self.iconView.frame =   CGRectMake(cellW - iconWidth - 15, (cellH-iconWidth)/2+15 , iconWidth,iconWidth);
        self.lineView.frame =   CGRectMake(0, cellH - 20, cellW-5, 0.5);
        self.appIconView.frame =   CGRectMake(10, cellH - 15, appiconW,appiconW);
        self.appNameLabel.frame = CGRectMake(25.0f, cellH - 20, 180.f, 21.f);
    }
    else
    {
        self.titleLabel.frame = CGRectMake(15.0f, 5.f, 210.f, 40.f);
        self.contentLabel.frame = CGRectMake(15.0f, 48.f, contentSize.width, contentSize.height);
        self.iconView.frame =   CGRectMake(cellW - iconWidth - 15+5, (cellH-iconWidth)/2+15, iconWidth,iconWidth);
        self.lineView.frame =   CGRectMake(5, cellH - 20, cellW-5, 0.5);
        self.appIconView.frame =   CGRectMake(15, cellH- 15, appiconW,appiconW);
        self.appNameLabel.frame = CGRectMake(30.0f, cellH - 20, 180.f, 21.f);
    }
}

- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
{
    NSString *stateString = state == UIControlStateNormal? @"normal" : @"pressed";
    NSString *imageName = nil;
    if (outgoing)
    {
        imageName = @"icon_sender_text_node_";
    }
    else
    {
        imageName = @"icon_receiver_node_";
    }
    imageName = [imageName stringByAppendingString:stateString];
    UIImage*image =  [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{20,25,10,20}") resizingMode:UIImageResizingModeStretch];
    return  image;
}

@end
