//
//  CJUserSelectTableViewCell.h
//  Runner
//
//  Created by chenyn on 2019/9/29.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMContactSelectConfig.h"

@class NIMGroupUser;

NS_ASSUME_NONNULL_BEGIN

@interface CJUserSelectTableViewCell : UITableViewCell

//@property (nonatomic, assign) BOOL selected;

- (void)configData:(NIMGroupUser *)user
            config:(id <NIMContactSelectConfig>)config;

@end

NS_ASSUME_NONNULL_END
