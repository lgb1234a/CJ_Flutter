> 这次native重构抛弃了以往基于NIMDemo工程开发的方式，需要按照既定业务来梳理所有的内容，这其中最核心的模块就是NIMKit+各类自定义消息。iOS NIMKit由cocoapods集成，方便后续维护升级，所有的自定义内容按照继承NIM类+可配置文件的形式进行。

## 框架梳理

```
Runner
|
|---- Base/ #基础代码，例如VC的基类，navigationVC的基类，pch文件
|
|---- Contacts/  #通讯录模块相关代码
|
|---- Hybrid/    #native和flutter桥接代码
|
|---- Login/     #登录模块相关代码
|
|---- Mine/      #我的模块相关代码
|
|---- Session/   #会话模块相关代码
|        |
|        |---- NTES/    #NIMDemo中拿过来的工具代码
|        |
|        |---- SessionViewController/   #聊天页面相关代码
|        |           |
|        |           |---- BubbleCell/  #气泡cell相关
|        |           |
|        |           |---- Config/      #聊天session和cell的相关配置
|        |           |
|        |           |---- Layout/      #cell布局的相关配置
|        |           |
|        |           |---- Manager/     #支付、红包等相关业务管理类
|        |
|        |---- Util/    #聊天相关工具类
|
|
|____ Vendor/    #第三方库、framework



CJBase私有仓库:维护的独立git仓库，修改后需要在该路径下，再提交代码到远端仓库，和主工程剥离开，便于维护和依赖给flutter插件使用
|
|---- Base/    #基础代码
|
|---- Category/   #扩展
|
|____ Network/   #网络请求相关
```

## 代码规范

1. 命名规范：统一采用驼峰体命名变量，方法名，方法名首字母禁止大写，合理利用空格，行间距要规范，类名一律以大写CJ开头，文件夹名字首字母一律大写，命名要符合英文阅读规范，尽量参照官方命名方式，做到简明易懂。
2. **异步代码调用：采用coobjc框架，提高代码的可读性和可维护性，摒弃block嵌套block，杜绝嵌套地狱。**
3. **图片引入：所有图片一律只引入2x格式，不需要额外引入3x图片，减小包体积大小。除非设计对UI精细度有明确要求。**

## 对比NIMDemo框架的改进点

> 主要针对以往在解析和配置自定义消息的时候，往往需要引入大量的自定义类，导致代码的可维护性和可读性极差等问题进行优化。优化过程中我采用了反射+协议的方式，将大量需要显示引入的自定义类，通过运行时反射找到类名，再运用协议声明，将所有的胶水代码维护在自定义类的内部，这样不仅大大提升了代码的通读性，还提升了可维护性。

维护前后代码对比：
AttachmentDecoder重构前
```
#import "NTESCustomAttachmentDecoder.h"
#import "NTESCustomAttachmentDefines.h"
#import "NTESJanKenPonAttachment.h"
#import "NTESSnapchatAttachment.h"
#import "NTESChartletAttachment.h"
#import "NTESWhiteboardAttachment.h"
#import "NTESRedPacketAttachment.h"
#import "NTESRedPacketTipAttachment.h"
#import "NSDictionary+NTESJson.h"
#import "NTESSessionUtil.h"
#import "NTESPersonalCardAttachment.h"
#import "NTESWebPageAttachment.h"
#import "NTESShareAppAttachment.h"
#import "NTESShareLinkAttachment.h"
#import "NTESAliPayRedPacketAttachment.h"
#import "NTESAliPayRedPacketTipAttachment.h"
#import "NTESShakeAttachment.h"
#import "NTESRecordAttachment.h"
#import "NTESYouXiRedPacketTipAttachment.h"
#import "NTESYouXiRedPacketAttachment.h"
#import "NTESYouXiTransferAttachment.h"
#import "NTESYouxiTransferReceiptAttachment.h"
#import "NTESMFRedPacketAttachment.h"
#import "NTESMFRedPacketTipAttachment.h"
#import "NTESUpdateInfoAttachment.h"
#import "NTESArticleNotificationAttachment.h"
#import "NTESScreenShotsAttachment.h"
#import "NTESPayAssistantAttachment.h"
#import "NTESSysAssistantAttachment.h"
#import "YYModel.h"
#import "NTESScreenBanRedAttachment.h"

@implementation NTESCustomAttachmentDecoder
- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<NIMCustomAttachment> attachment = nil;

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            NSInteger type     = [dict jsonInteger:CMType];
            NSDictionary *data = [dict jsonDict:CMData];
            switch (type) {
                case CustomMessageTypeJanKenPon:
                {
                    attachment = [[NTESJanKenPonAttachment alloc] init];
                    ((NTESJanKenPonAttachment *)attachment).value = [data jsonInteger:CMValue];
                }
                    break;
                case CustomMessageTypeSnapchat:
                {
                    attachment = [[NTESSnapchatAttachment alloc] init];
                    ((NTESSnapchatAttachment *)attachment).md5 = [data jsonString:CMMD5];
                    ((NTESSnapchatAttachment *)attachment).url = [data jsonString:CMURL];
                    ((NTESSnapchatAttachment *)attachment).isFired = [data jsonBool:CMFIRE];
                }
                    break;
                case CustomMessageTypeChartlet:
                {
                    attachment = [[NTESChartletAttachment alloc] init];
                    ((NTESChartletAttachment *)attachment).chartletCatalog = [data jsonString:CMCatalog];
                    ((NTESChartletAttachment *)attachment).chartletId      = [data jsonString:CMChartlet];
                }
                    break;
                case CustomMessageTypeWhiteboard:
                {
                    attachment = [[NTESWhiteboardAttachment alloc] init];
                    ((NTESWhiteboardAttachment *)attachment).flag = [data jsonInteger:CMFlag];
                }
                    break;
                case CustomMessageTypeRedPacket:
                {
                    attachment = [[NTESRedPacketAttachment alloc] init];
                    ((NTESRedPacketAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESRedPacketAttachment *)attachment).content = [data jsonString:CMRedPacketContent];
                    ((NTESRedPacketAttachment *)attachment).redPacketId = [data jsonString:CMRedPacketId];
                    ((NTESRedPacketAttachment *)attachment).money = [data jsonString:CMRedPacketMoney];
                    ((NTESRedPacketAttachment *)attachment).count = [[data jsonString:CMRedPacketCount] integerValue];
                    ((NTESRedPacketAttachment *)attachment).status = [[data jsonString:CMRedPacketStatus] integerValue];
                }
                    break;
                case CustomMessageTypeRedPacketTip:
                {
                    attachment = [[NTESRedPacketTipAttachment alloc] init];
                    ((NTESRedPacketTipAttachment *)attachment).sendPacketId = [data jsonString:CMRedPacketSendId];
                    ((NTESRedPacketTipAttachment *)attachment).packetId  = [data jsonString:CMRedPacketId];
                    ((NTESRedPacketTipAttachment *)attachment).isGetDone = [data jsonString:CMRedPacketDone];
                    ((NTESRedPacketTipAttachment *)attachment).openPacketId = [data jsonString:CMRedPacketOpenId];
                    
                }
                    break;
                    
                case CustomMessageTypeMFRedPacket:
                {
                    attachment = [[NTESMFRedPacketAttachment alloc] init];
                    ((NTESMFRedPacketAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESMFRedPacketAttachment *)attachment).content = [data jsonString:CMRedPacketContent];
                    ((NTESMFRedPacketAttachment *)attachment).redPacketId = [data jsonString:CMRedPacketId];
                    ((NTESMFRedPacketAttachment *)attachment).money = [data jsonString:CMRedPacketMoney];
                    ((NTESMFRedPacketAttachment *)attachment).count = [[data jsonString:CMRedPacketCount] integerValue];
                    ((NTESMFRedPacketAttachment *)attachment).status = [[data jsonString:CMRedPacketStatus] integerValue];
                }
                    break;
                    
                case CustomMessageTypeMFRedPacketTip:
                {
                    attachment = [[NTESMFRedPacketTipAttachment alloc] init];
                    ((NTESMFRedPacketTipAttachment *)attachment).sendPacketId = [data jsonString:CMRedPacketSendId];
                    ((NTESMFRedPacketTipAttachment *)attachment).packetId  = [data jsonString:CMRedPacketId];
                    ((NTESMFRedPacketTipAttachment *)attachment).isGetDone = [data jsonString:CMRedPacketDone];
                    ((NTESMFRedPacketTipAttachment *)attachment).openPacketId = [data jsonString:CMRedPacketOpenId];
                }
                    break;
                // 自定义的个人名片
                case CustomMessageTypePersonalCard:
                {
                    attachment = [[NTESPersonalCardAttachment alloc] init];
                    ((NTESPersonalCardAttachment *)attachment).accid = [data jsonString:CMPersonalCardAccid];
                    ((NTESPersonalCardAttachment *)attachment).nickname  = [data jsonString:CMPersonalCardNickName];
                    ((NTESPersonalCardAttachment *)attachment).imageurl = [data jsonString:CMPersonalCardUrl];
                }
                    break;
                    // 版本更新推送
                case CustomMessageTypeUpdateInfo:
                {
                    attachment = [[NTESUpdateInfoAttachment alloc] init];
                    ((NTESUpdateInfoAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESUpdateInfoAttachment *)attachment).content  = [data jsonString:CMRedPacketContent];
                    ((NTESUpdateInfoAttachment *)attachment).log_time = [data jsonString:@"log_time"];
                }
                    break;
                    
                case CustomMessageTypeArticleNotification:
                {
                    // 解析推文的数据
                    attachment = [[NTESArticleNotificationAttachment alloc] init];
                    NSArray *articles = [data jsonArray:@"articles"];
                    ((NTESArticleNotificationAttachment *)attachment).articles = [NSArray yy_modelArrayWithClass:NTESArticleModel.class json:articles];
                }
                    break;
                    // 网页分享
                case CustomMessageTypeWebPage:
                {
                    attachment = [[NTESWebPageAttachment alloc] init];
                    ((NTESWebPageAttachment *)attachment).title = [data jsonString:CMWebPageTitle];
                    ((NTESWebPageAttachment *)attachment).content  = [data jsonString:CMWebPageContent];
                    ((NTESWebPageAttachment *)attachment).weburl = [data jsonString:CMWebPageUrl];
                    ((NTESWebPageAttachment *)attachment).imageData = [data jsonString:CMWebPageImageData];
                    ((NTESWebPageAttachment *)attachment).appname = [data jsonString:CMWebPageAppName];
                    ((NTESWebPageAttachment *)attachment).appicon = [data jsonString:CMWebPageAppIcon];
                    ((NTESWebPageAttachment *)attachment).extention = [data jsonString:CMWebPageAppExtention];
                }
                    // 支红包
                case CustomMessageTypeAliPayRedPacket:
                {
                    attachment = [[NTESAliPayRedPacketAttachment alloc] init];
                    ((NTESAliPayRedPacketAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESAliPayRedPacketAttachment *)attachment).content = [data jsonString:CMRedPacketContent];
                    ((NTESAliPayRedPacketAttachment *)attachment).redPacketId = [data jsonString:CMRedPacketId];
                    ((NTESAliPayRedPacketAttachment *)attachment).money = [data jsonString:CMRedPacketMoney];
                    ((NTESAliPayRedPacketAttachment *)attachment).count = [[data jsonString:CMRedPacketCount] integerValue];
                    ((NTESAliPayRedPacketAttachment *)attachment).status = [[data jsonString:CMRedPacketStatus] integerValue];
                }
                    break;
                    // 拆支红包
                case CustomMessageTypeAliPayRedPacketTip:
                {
                    attachment = [[NTESAliPayRedPacketTipAttachment alloc] init];
                    ((NTESAliPayRedPacketTipAttachment *)attachment).sendPacketId = [data jsonString:CMRedPacketSendId];
                    ((NTESAliPayRedPacketTipAttachment *)attachment).packetId  = [data jsonString:CMRedPacketId];
                    ((NTESAliPayRedPacketTipAttachment *)attachment).isGetDone = [data jsonString:CMRedPacketDone];
                    ((NTESAliPayRedPacketTipAttachment *)attachment).openPacketId = [data jsonString:CMRedPacketOpenId];
                }
                    break;
                    
                case CustomMessageTypeYouXiRedPacket:
                {
                    // 游兮红包
                    attachment = [[NTESYouXiRedPacketAttachment alloc] init];
                    ((NTESYouXiRedPacketAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESYouXiRedPacketAttachment *)attachment).content = [data jsonString:CMRedPacketContent];
                    ((NTESYouXiRedPacketAttachment *)attachment).redPacketId = [data jsonString:CMRedPacketId];
                    ((NTESYouXiRedPacketAttachment *)attachment).money = [data jsonString:CMRedPacketMoney];
                    ((NTESYouXiRedPacketAttachment *)attachment).count = [[data jsonString:CMRedPacketCount] integerValue];
                    ((NTESYouXiRedPacketAttachment *)attachment).status = [[data jsonString:CMRedPacketStatus] integerValue];
                }
                    
                    break;
                    
                case CustomMessageTypeYXTransfer:
                {
                    // 游兮转账
                    attachment = [[NTESYouXiTransferAttachment alloc] init];
                    ((NTESYouXiTransferAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESYouXiTransferAttachment *)attachment).content = [data jsonString:CMRedPacketContent];
                    ((NTESYouXiTransferAttachment *)attachment).transferId = [data jsonString:CMTransferId];
                    ((NTESYouXiTransferAttachment *)attachment).amount = [data jsonString:CMTransferMoney];
                }
                    break;
                case CustomMessageTypeYXTransferReceipt:
                {
                    // 游兮转账回执
                    attachment = [[NTESYouxiTransferReceiptAttachment alloc] init];
                    ((NTESYouxiTransferReceiptAttachment *)attachment).title = [data jsonString:CMRedPacketTitle];
                    ((NTESYouxiTransferReceiptAttachment *)attachment).content = [data jsonString:CMRedPacketContent];
                    ((NTESYouxiTransferReceiptAttachment *)attachment).transferId = [data jsonString:CMTransferId];
                    ((NTESYouxiTransferReceiptAttachment *)attachment).amount = [data jsonString:CMTransferMoney];
                    ((NTESYouxiTransferReceiptAttachment *)attachment).status = [data jsonString:@"transferStatus"].integerValue;
                    ((NTESYouxiTransferReceiptAttachment *)attachment).sendPacketId = [data jsonString:@"sendPacketId"];
                    ((NTESYouxiTransferReceiptAttachment *)attachment).openPacketId = [data jsonString:@"openPacketId"];
                }
                    break;
                case CustomMessageTypeYouXiRedPacketTip:
                {
                    // 拆游兮红包
                    attachment = [[NTESYouXiRedPacketTipAttachment alloc] init];
                    ((NTESYouXiRedPacketTipAttachment *)attachment).sendPacketId = [data jsonString:CMRedPacketSendId];
                    ((NTESYouXiRedPacketTipAttachment *)attachment).packetId  = [data jsonString:CMRedPacketId];
                    ((NTESYouXiRedPacketTipAttachment *)attachment).isGetDone = [data jsonString:CMRedPacketDone];
                    ((NTESYouXiRedPacketTipAttachment *)attachment).openPacketId = [data jsonString:CMRedPacketOpenId];
                }
                    
                    break;
                    // 分享游戏
                ...后面太多了，不全部引入了
```


AttachmentDecoder重构后
```
#import "CJCustomAttachmentDecoder.h"
#import "CJCustomAttachmentDefines.h"

@implementation CJCustomAttachmentDecoder

- (id<CJCustomAttachmentCoding>)decodeAttachment:(NSString *)content
{
    id<CJCustomAttachmentCoding> attachment = nil;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if(!data) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:nil];
    if (data && [dict isKindOfClass:[NSDictionary class]]) {
        NSInteger type     = [[dict objectForKey:@"type"] integerValue];
        NSDictionary *data = [dict objectForKey:@"data"];
        
        NSString *className = attachmentNameForType(type);
        Class cls = NSClassFromString(className);
        if([cls instancesRespondToSelector:@selector(initWithPrepareData:)])
        {
            attachment = [[cls alloc] initWithPrepareData:data];
        }
    }
    
    attachment = [attachment isValid]? attachment : nil;
    return attachment;
}

@end
```

**相对的，所有的decoder代码都维护在attachment类自身，这样在后续修改或者删除一个自定义消息的时候，不用担心会因为修改那一长串胶水代码，而会引起其他模块问题，提升了代码解耦的同时，并降低了维护成本和测试成本。还有许多类似的优化，就不一一列举了**

## 新框架下，新增自定义消息的流程

CJCustomAttachmentDefines类
```
typedef NS_ENUM(NSInteger, CJCustomMessageType){
    CustomMessageTypeJanKenPon  = 1, //剪子石头布
    CustomMessageTypeSnapchat   = 2, //阅后即焚
    CustomMessageTypeChartlet   = 3, //贴图表情
    CustomMessageTypeWhiteboard = 4, //白板会话
    CustomMessageTypeRedPacket  = 5, //红包消息
    CustomMessageTypeRedPacketTip = 6, //红包提示消息
    
    //自定义的消息类型
    CustomMessageTypePersonalCard = 7, // 个人名片
    CustomMessageTypeWebPage      = 8, // 网页链接
    
    CustomMessageTypeAliPayRedPacket    = 9, //红包消息
    CustomMessageTypeAliPayRedPacketTip = 10, //红包提示消息
    
    //    CustomMessageTypeShareImage   = 11, // 分享图片
    CustomMessageTypeShareApp     = 12, // 分享游戏
    CustomMessageTypeShareLink    = 13, // 分享链接
    CustomMessageTypeShake   = 14, // 分享链接
    CustomMessageTypeRecord   = 16, // 战绩消息
    
    CustomMessageTypeCloudRedPacket = 19, //  云红包
    CustomMessageTypeCloudRedPacketTip = 20, //
    
    CustomMessageTypeSystemNotification = 21, // 擦肩小助手系统通知
    CustomMessageTypeUpdateInfo = 22,  // 擦肩小助手版本更新消息
    CustomMessageTypeRefund = 23,      // 擦肩小助手退款消息
    CustomMessageTypeScreenShotsNotice     = 24, //截屏通知
    //    CustomMessageTypeHelperNotice     = 25, //小助手通知
    CustomMessageTypeArticleNotification  = 26, // 文章推送
    CustomMessageTypeBanRedPacket  = 27, // 禁止领红包
    CustomMessageTypeYeeRedPacket = 28, //易红包
    CustomMessageTypeYeeRedPacketTip = 29,
    CustomMessageTypeYeeTransfer = 30, //易转账
    CustomMessageTypeYeeTransferReceipt = 31,//(接收转账,退回转账)
};

// type -> class name
NSDictionary *attachmentMapping(void);
NSString *attachmentNameForType(CJCustomMessageType type);


@protocol CJCustomAttachmentCoding <NIMCustomAttachment>

@required

/**
 内容是否有效
 
 @return bool
 */
- (BOOL)isValid;

/**
 拼装attachment model
 
 @param data
 @param type
 */
- (instancetype)initWithPrepareData:(NSDictionary *)data;

/**
 是否显示头像
 
 @return bool
 */
- (BOOL)shouldShowNickName;

/**
 是否显示头像
 
 @return bool
 */
- (BOOL)shouldShowAvatar;


/**
 新消息缩略语
 
 @return string
 */
- (NSString *)newMsgAcronym;

@optional

/**
 从attachment model自定义消息
 之前的NTESSessionMsgConverter拆分出来，由各自attachment model类维护
 
 @return 消息
 */
- (NIMMessage *)msgFromAttachment;

@end


@protocol CJCustomAttachmentInfo <NSObject>

@optional

- (NSString *)cellContent:(NIMMessage *)message;

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width;

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message;

- (NSString *)formatedMessage;

- (UIImage *)showCoverImage;

- (BOOL)shouldShowAvatar;

- (void)setShowCoverImage:(UIImage *)image;

- (BOOL)canBeRevoked;

- (BOOL)canBeForwarded;

@end
```

这个类维护了一套自定义消息的类型映射和两个协议，`CJCustomAttachmentCoding`协议负责自定义消息model的组装和相关配置，`CJCustomAttachmentInfo`协议负责自定义消息布局的配置。**只要实现这个类里面的协议即可完成自定义消息的添加，不需要再在额外的地方添加任何胶水代码。**

* 第一步：`CJCustomMessageType`枚举里面，如果是新增的类型，则添加枚举值，并在`CJCustomAttachmentDefines.m`里面添加映射。
* 第二步：实现自定义消息的model类，用于管理自定义消息的数据，参见`CJYeePayRedPacketAtachment`。
* 第三步：实现自定义消息的contentView类，用于管理自定义消息的UI，参见`CJYeeRedPacketContentView`。

**只需要以上三步，就完成了一个自定义消息的添加。**
