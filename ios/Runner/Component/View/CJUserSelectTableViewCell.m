//
//  CJUserSelectTableViewCell.m
//  Runner
//
//  Created by chenyn on 2019/9/29.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJUserSelectTableViewCell.h"
#import "NIMGroupedUsrInfo.h"
#import "cokit.h"

@interface CJUserSelectTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectStatusBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *showName;
@property (weak, nonatomic) IBOutlet UILabel *userTip;

@end

@implementation CJUserSelectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectStatusBtn.selected = selected;
}

- (void)configData:(NIMGroupUser *)user
            config:(id <NIMContactSelectConfig>)config
{
    NIMKitInfo *info = [config getInfoById:user.memberId];
    
    self.showName.text = info.showName;
    self.avatarImgView.image = info.avatarImage;
    co_launch(^{
        NSURL *url = [NSURL URLWithString:info.avatarUrlString];
        NSData *data = await([NSData async_dataWithContentsOfURL:url]);
        UIImage *image = await([UIImage async_imageWithData:data]);
        self.avatarImgView.image = image;
    });
}

@end
