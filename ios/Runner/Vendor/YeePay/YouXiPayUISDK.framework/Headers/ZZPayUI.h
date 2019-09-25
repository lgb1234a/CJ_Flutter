//
//  PayUITest.h
//  YouXiPayUISDK
//
//  Created by chenyn on 2019/5/10.
//  Copyright © 2019 youxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZZPayProtocol <NSObject>

@required

/**
 领取红包的回调

 @param sender 红包发送人
 @param openerId 抢红包的人id
 @param packetId 红包id
 */
- (void)didOpenRedPacket:(NSString *)sender
            openPacketId:(NSString *)openerId
                packetId:(NSString *)packetId
               isGetDone:(BOOL)isGetDone;

@end

@interface ZZAvatarModel : NSObject

@property (nonatomic, copy) NSString *u_id;
@property (nonatomic, copy) NSString *avatarUrl;

/**
 0：未知
 1：男
 2：女
 */
@property (nonatomic, assign) NSInteger gender;

@end

typedef void(^selectedIds)(NSArray <ZZAvatarModel *>*ids);

@interface ZZPayUI : NSObject

/**
 初始化支付SDK

 @param merchantNo 商户id
 @param userNo 商户平台下的用户id
 */
+ (void)initializePaySDKWithMerchantNo:(NSString *)merchantNo
                                userNo:(NSString *)userNo;

/**
 当前用户登出操作
 */
+ (void)didLogout;

/**
 拉起我的钱包页面

 @param vc 根页面
 */
+ (void)showMyWallet:(UIViewController *)vc;


/**
 拉起红包编辑页面

 @param vc 根页面
 @param sessionId 会话id
 @param memberNum 群成员数量
 @param team 是否是群聊
 @param block 跳转群联系人选择页的回调（selectedIds 返回选中的成员id，最多5人）
 */
+ (void)showSendRedPEditView:(UIViewController *)vc
                   sessionId:(NSString *)sessionId
                   memberNum:(NSInteger)num
                      isTeam:(BOOL)team
    jumpToTeamMemberSelector:(UIViewController * (^)(selectedIds callBack, NSArray *crtIds))block;


/**
 展示红包详情页

 @param vc 根页面
 @param rp_id 红包id
 */
+ (void)showRedPacketDetailFromVC:(UIViewController *)vc
                      redPacketId:(NSString *)rp_id
                           status:(void (^)(NSInteger status))result;

/**
 弹出红包待开启页

 @param fromVC 根页面
 @param rp_id 红包id
 @param teamSession 是否是群聊天
 @param result 状态回调
 @param openSuccess 拆红包成功回调
 */
+ (void)popRedPacketFromVC:(UIViewController *)fromVC
               redPacketId:(NSString *)rp_id
             inTeamSession:(BOOL)teamSession
                    status:(void (^)(NSInteger status))result
               openSuccess:(void (^)(NSString *sender,NSString *openerId,NSString *packetId,BOOL isGetDone))openSuccess;


/**
 发起转账页面

 @param fromVC 根页面
 @param to_user_no 商户平台下用户的唯一标识
 */
+ (void)presentTransferAccountsViewFromVc:(UIViewController *)fromVC
                              to_user_no:(NSString *)to_user_no;



/**
 确认收款页面(收款详情页面)

 @param fromVC fromVC 根页面
 @param transfer_id 转账id
 @param result status(1：支付成功 2: 支付失败 3. 已接收 4.已拒收 5.超时退款)
 */
+ (void)presentReceiveTransferAccountsViewFromVc:(UIViewController *)fromVC
                                     transfer_id:(NSString *)transfer_id
                                          result:(void (^)(NSInteger status))result;

/**
 红包详情页面

 @param vc 根页面
 @param trp_id  红包ID
 @param result status(0. 待领取  1.部分被领取  2.被领取  3.超时已退款)
 */
+ (void)presentMyDecRedViewFromVc:(UIViewController *)vc
                           trp_id:(NSString *)trp_id
                        rp_status:(void (^)(NSInteger status))result;



@end

NS_ASSUME_NONNULL_END
