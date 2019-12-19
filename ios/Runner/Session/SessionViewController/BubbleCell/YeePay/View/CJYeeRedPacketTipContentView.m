//
//  CJYeeRedPacketTipContentView.m
//  Runner
//
//  Created by chenyn on 2019/9/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJYeeRedPacketTipContentView.h"
#import <M80AttributedLabel.h>
#import "CJCustomAttachmentDefines.h"

@interface CJYeeRedPacketTipContentView()<M80AttributedLabelDelegate>

@property (nonatomic,strong) M80AttributedLabel *label;

@end

@implementation CJYeeRedPacketTipContentView

// 初始化UI
- (instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:14.0f];
        _label.textColor = Main_TextGrayColor;
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        _label.delegate = self;
        _label.underLineForLink = NO;
        _label.textAlignment = kCTTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

// 刷新数据
- (void)refresh:(NIMMessageModel *)model{
    [super refresh:model];
    NIMCustomObject *object = (NIMCustomObject *)model.message.messageObject;
    id<CJCustomAttachmentInfo> attachment = (id<CJCustomAttachmentInfo>)object.attachment;
    [self.label setText:nil];
    if ([attachment respondsToSelector:@selector(formatedMessage)]) {
        NSString *formatedMessage = attachment.formatedMessage;
        [self.label appendText:formatedMessage];
        NSRange range = [formatedMessage rangeOfString:@"红包"];
        if (range.location != NSNotFound){
            //由于还有个 icon , 需要将 range 往后挪一个位置
            range = NSMakeRange(range.location, range.length);
            [self.label addCustomLink:model forRange:range linkColor:Main_redColor];
        }
    }
}

// 气泡背景图
- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
{
    UIEdgeInsets insets = UIEdgeInsetsFromString(@"{8,20,8,20}");
    return [[UIImage imageNamed:@""] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
}

// 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
}


#pragma mark - M80AttributedLabelDelegate
- (void)m80AttributedLabel:(M80AttributedLabel *)label
             clickedOnLink:(id)linkData
{
    if ([self.delegate respondsToSelector:@selector(onCatchEvent:)]) {
        NIMKitEvent *event = [[NIMKitEvent alloc] init];
        event.messageModel = self.model;
        event.data = self;
        [self.delegate onCatchEvent:event];
    }
}

@end
