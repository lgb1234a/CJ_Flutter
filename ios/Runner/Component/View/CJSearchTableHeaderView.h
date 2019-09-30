//
//  CJSearchTableHeaderView.h
//  Runner
//
//  Created by chenyn on 2019/9/30.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NIMGroupMemberProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol CJSearchHeaderDelegate <NSObject>

@required
/**
 搜索状态变化
 
 @param inSearching 是否正在搜索
 */
- (void)searchStatusChanged:(BOOL)inSearching;

/**
 取消选中

 @param item
 */
- (void)searchHeaderDeselect:(id<NIMGroupMemberProtocol>)item;


/**
 搜索文本发生变化

 @param key 搜索关键词
 */
- (void)searchValueChanged:(NSString *)key;

@end

@interface CJSearchTableHeaderView : UIView

@property (nonatomic, assign) id<CJSearchHeaderDelegate> delegate;

- (void)refresh:(NSArray <id<NIMGroupMemberProtocol>>*)dataSource;

@end

NS_ASSUME_NONNULL_END
