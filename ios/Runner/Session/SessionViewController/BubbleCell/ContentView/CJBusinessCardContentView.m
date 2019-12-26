//
//  CJBusinessCardContentView.m
//  Runner
//
//  Created by chenyn on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJBusinessCardContentView.h"
#import "NIMAvatarImageView.h"
#import "UIImage+NIMKit.h"
#import "CJBusinessCardAttachment.h"

@interface CJBusinessCardContentView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic,strong) UILabel *bottomLabel;

@property (nonatomic, strong) UIImageView *avatarView;

@end

@implementation CJBusinessCardContentView

- (instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
        // 内容布局
        _lineView= [UIView new];
        _lineView.backgroundColor = Main_lineColor;
        [self addSubview:_lineView];
        
        _bottomLabel = [UILabel new];
        _bottomLabel.text = @"个人名片";
        _bottomLabel.textColor = Main_TextGrayColor;
        _bottomLabel.font = [UIFont systemFontOfSize:10.f];
        [self addSubview:self.bottomLabel];
        
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarView.layer.cornerRadius = 6.0f;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_avatarView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
        _titleLabel.textColor = Main_TextBlackColor;
        _titleLabel.numberOfLines = 1;
        [self addSubview:_titleLabel];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont systemFontOfSize:12.f];
        _subTitleLabel.textColor = Main_TextGrayColor;
        _subTitleLabel.numberOfLines = 1;
        [self addSubview:_subTitleLabel];
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
    
    NIMCustomObject *object = (NIMCustomObject *)data.message.messageObject;
    CJBusinessCardAttachment *attachment = (CJBusinessCardAttachment *)object.attachment;

    self.titleLabel.text = attachment.nickName;
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:attachment.accid option:nil];
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:attachment.accid];
    
    NSString *avatarUrl = cj_empty_string(attachment.imageUrl) ? info.avatarUrlString : attachment.imageUrl;
    
    if(cj_empty_string(avatarUrl)) {
        UIImage *img = [UIImage nim_imageInKit:@"avatar_user"];
        self.avatarView.image = img;
    }else {
        co_launch(^{
            NSData *data = await([NSData async_dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]]);
            UIImage *avatar =  await([UIImage async_imageWithData:data]);
            self.avatarView.image = avatar;
        });
    }
    
    NSDictionary *d =  [user.userInfo.ext jsonStringToDictionaryOrArray];
    self.subTitleLabel.text = [d objectForKey:@"cajian_id"] ? : @"";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cellH = CGRectGetHeight(self.frame);
    CGFloat cellW = CGRectGetWidth(self.frame);
    CGFloat avatarWidth = 50.f;
    
    CGFloat padding_x = 10.f;
    CGFloat padding_y = 5.f;
    CGFloat padding_trailing = 10.f;
    CGFloat padding_bottom = 3.f;
    
    BOOL outgoing = self.model.message.isOutgoingMsg;
    if(!outgoing) {
        padding_x = 15.f;
        padding_trailing = 5.f;
    }
    
    _avatarView.frame = CGRectMake(padding_x,
                                   padding_y,
                                   avatarWidth,
                                   avatarWidth);
    CGFloat columnSpace = 8.f;
    _titleLabel.frame = CGRectMake(padding_x + avatarWidth + columnSpace,
                                   padding_y + padding_y,
                                   cellW - padding_x - avatarWidth - columnSpace - padding_trailing,
                                   18.f);
    CGFloat rowSpace = 5.f;
    _subTitleLabel.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),
                                      CGRectGetMaxY(_titleLabel.frame) + rowSpace,
                                      CGRectGetWidth(_titleLabel.frame),
                                      14.f);
    _lineView.frame = CGRectMake(padding_x,
                                 CGRectGetMaxY(_avatarView.frame) + 12.f,
                                 cellW - padding_x - padding_trailing,
                                 .5f);
    
    _bottomLabel.frame = CGRectMake(padding_x,
                                    cellH - 15 - padding_y - padding_bottom,
                                    cellW - padding_x - padding_trailing,
                                    15.f);
}

- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing{
    
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
