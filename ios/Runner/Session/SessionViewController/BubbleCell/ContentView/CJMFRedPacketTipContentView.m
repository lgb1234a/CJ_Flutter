//
//  CJMFRedPacketTipContentView.m
//  Runner
//
//  Created by chenyn on 2019/12/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJMFRedPacketTipContentView.h"
#import "CJCustomAttachmentDefines.h"

@interface CJMFRedPacketTipContentView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation CJMFRedPacketTipContentView

// 初始化UI
- (instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:14.0f];
        _label.textColor = Main_TextGrayColor;
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

// 刷新数据
- (void)refresh:(NIMMessageModel *)model{
    [super refresh:model];
    
    self.label.text = @"易宝版暂不支持擦肩红包，敬请期待～";
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

@end
