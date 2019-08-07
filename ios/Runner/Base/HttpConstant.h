//
//  HttpConstant.h
//  CaJian
//
//  Created by Apple on 2018/11/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#ifndef HttpConstant_h
#define HttpConstant_h

#define kBase @"https://api.youxi2018.cn"

#define kBaseUrl [NSString stringWithFormat:@"%@",kBase]
//登陆
#define KLoginUrl [NSString stringWithFormat:@"%@/g2/login/vecode",kBaseUrl]

//请求验证码
#define KCodeUrl [NSString stringWithFormat:@"%@/g2/vecode/send",kBaseUrl]

// 冻结账号
#define KFreezeAccountUrl [NSString stringWithFormat:@"%@/g2/user/forzen/account",kBaseUrl]

// 解冻账号
#define KUnFreezeAccountUrl [NSString stringWithFormat:@"%@/g2/user/thaw/account",kBaseUrl]

//注册
#define KRegisterUrl [NSString stringWithFormat:@"%@/g2/user/register",kBaseUrl]

// 微信登录
#define kWechatLoginUrl [NSString stringWithFormat:@"%@/g2/login/wx/new",kBaseUrl]

// 查找用户
#define kSearchUserUrl [NSString stringWithFormat:@"%@/g2/accid/select",kBaseUrl]

// 密码登录
#define kPasswordLoginUrl [NSString stringWithFormat:@"%@/g2/login/passwd",kBaseUrl]

// 修改擦肩号
#define kUpdateCjidUrl [NSString stringWithFormat:@"%@/g2/cajianid/update",kBaseUrl]

// 查询密码设置状态
#define kPasswordStatusUrl [NSString stringWithFormat:@"%@/g2/passwd/exist",kBaseUrl]

// 设置密码
#define kSetPasswordUrl [NSString stringWithFormat:@"%@/g2/passwd/set",kBaseUrl]

// 修改密码
#define kUpdatePasswordUrl [NSString stringWithFormat:@"%@/g2/passwd/update",kBaseUrl]

// 忘记密码 通过手机号 获得accid 然后调用set
#define kForgetPasswordUrl [NSString stringWithFormat:@"%@/g2/passwd/forget",kBaseUrl]

// 复制通讯录
#define kCopyContacts [NSString stringWithFormat:@"%@/g2/friend/copy",kBaseUrl]

//获取最新版本
#define kGetNewVersionUrl [NSString stringWithFormat:@"%@/g2/version/isnew",kBaseUrl]

//获取魔方token
#define kGetMoFangTokenUrl [NSString stringWithFormat:@"%@/g2/mf/token/get",kBaseUrl]

// 创建群 抄送给服务端
#define kPostTeamLogUrl [NSString stringWithFormat:@"%@/g2/group/create/log",kBaseUrl]

// 手机通讯录
#define kPostPhoneAddressUrl [NSString stringWithFormat:@"%@/g2/friend/list",kBaseUrl]

// 通讯录邀请好友
#define kPostInviteFriendUrl [NSString stringWithFormat:@"%@/g2/friend/invite",kBaseUrl]

#define kQRCodeUrl      [NSString stringWithFormat:@"%@/v2/jump/",kBaseUrl]

//数据库操作链接
#define kInsertDataUrl      [NSString stringWithFormat:@"%@/g2/collect/append",kBaseUrl]

#define kDeleteDataUrl      [NSString stringWithFormat:@"%@/g2/collect/delete",kBaseUrl]

#define kSelectDataUrl      [NSString stringWithFormat:@"%@/g2/collect/select",kBaseUrl]

#define kSetTimeUrl      [NSString stringWithFormat:@"%@/g2/group/auto/receive/update",kBaseUrl]

#define kGetTimeUrl      [NSString stringWithFormat:@"%@/g2/group/auto/receive/select",kBaseUrl]

#define kChangePhoneNumUrl      [NSString stringWithFormat:@"%@/g2/user/phone/change",kBaseUrl]

// #帮助连接
#define kHelpUrl @"https://help.youxi2018.cn/app/help/index.html"

// 分享的链接
#define kShareUrl @"https://download.youxi2018.cn"

// 分享sdk注册链接
#define kRegisterAppUrl @"https://openapi.youxi2018.cn/g1/share/app/get"


// 用户协议
#define kAgreementUrl @"https://help.youxi2018.cn/agreement/user.html"

////////////////////////////////////////////////////////////////////{{
/////***********************  易宝钱包  **************************////
// 零钱查询
#define kAcquireBalance [NSString stringWithFormat:@"%@/g2/yeepay/user/query",kBaseUrl]
// 实名校验
#define kIsRealName [NSString stringWithFormat:@"%@/g2/yeepay/user/realname/exist",kBaseUrl]
// 实名认证
#define kRealNameAuthorize [NSString stringWithFormat:@"%@/g2/yeepay/user/realname",kBaseUrl]
// 绑定银行卡
#define kBindBankCard [NSString stringWithFormat:@"%@/g2/yeepay/bankcard/bind",kBaseUrl]
// 绑卡验证
#define kVerifyBindCard [NSString stringWithFormat:@"%@/g2/yeepay/bankcard/bind/verify",kBaseUrl]
// 绑卡列表
#define kCardList [NSString stringWithFormat:@"%@/g2/yeepay/bankcard/list",kBaseUrl]
// 解绑
#define kUnbindCard [NSString stringWithFormat:@"%@/g2/yeepay/bankcard/unbind",kBaseUrl]
// 充值提现
#define kRechargeOrWithDarw [NSString stringWithFormat:@"%@/g2/yeepay/wallet/op",kBaseUrl]
// 支付密码设置
#define kPwdSet [NSString stringWithFormat:@"%@/g2/yeepay/passwd/set",kBaseUrl]
// 支付密码验证
#define kPwdVerify [NSString stringWithFormat:@"%@/g2/yeepay/passwd/validate",kBaseUrl]
// 银行卡号验证
#define kBankCardVerify [NSString stringWithFormat:@"%@/g2/bankcard/check",kBaseUrl]
// 银行支持列表
#define kBankListAvailable [NSString stringWithFormat:@"%@/g2/bankcard/lists",kBaseUrl]
// 发送红包
#define kSendRedp [NSString stringWithFormat:@"%@/g2/mf/packet/send",kBaseUrl]
// 发送云红包
#define kSendMFRedp [NSString stringWithFormat:@"%@/g2/lq/packet/send",kBaseUrl]

// 服务端发送自定义消息
#define kSendCustomMessage [NSString stringWithFormat:@"%@/g2/group/forbid/sendmsg",kBaseUrl]

// 长时间未领取红包列表
#define kRedpacketList [NSString stringWithFormat:@"%@/g2/mf/packet/unreceived/list",kBaseUrl]

// 红包收发记录
#define kRedpacketRedcords [NSString stringWithFormat:@"%@/g2/group/packet/record/list",kBaseUrl]

/////***********************  易宝钱包  **************************////
////////////////////////////////////////////////////////////////////}}

// 群成员变动记录
#define kGroupMemberChange [NSString stringWithFormat:@"%@/g2/group/user/change",kBaseUrl]
// 群成员变动记录查询
#define kGroupMemberChangeQuery [NSString stringWithFormat:@"%@/g2/group/user/change/select",kBaseUrl]
// 禁止领取支付宝红包成员列表
#define kGroupForbidAlipayRedPacketList [NSString stringWithFormat:@"%@/g2/group/receive/forbid/list",kBaseUrl]
// 取消禁止领红包
#define kUnForbidAlipayRedPacket [NSString stringWithFormat:@"%@/g2/group/receive/unforbid",kBaseUrl]
// 禁止成员领支付宝红包
#define kForbidAlipayRedPacket [NSString stringWithFormat:@"%@/g2/group/receive/forbid",kBaseUrl]

#endif /* HttpConstant_h */
