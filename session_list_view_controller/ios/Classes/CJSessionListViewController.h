/**
 *  Created by chenyn on 2019-07-26
 *  会话列表页
 */

#import <NIMSessionListViewController.h>

@protocol CJSessionListDelegate <NSObject>

- (void)didSelectedCell:(NIMSession *)session;

@end

@interface CJSessionListViewController : NIMSessionListViewController

@property (nonatomic, assign) id <CJSessionListDelegate> delegate;

@end
