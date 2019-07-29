/**
 *  Created by chenyn on 2019-07-26
 *  会话页
 */

#import <NIMSessionViewController.h>

@protocol CJSessionDelegate <NSObject>



@end

@interface CJSessionViewController : NIMSessionViewController

@property (nonatomic, assign) id <CJSessionDelegate>delegate;

@end
