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

## flutter&native遇到的几个问题

### 如何管理页面堆栈

在解决这个问题的时候，我走了很多弯路，一开始打算是flutter为主，native为辅（毕竟是从零开始的新项目），然后在管理堆栈的时候遇到很多挑战，这种做法在flutter--push-->flutter很简单，当我要flutter--push-->native或者native--push-->flutter的时候，就蒙圈了。当时找了咸鱼的flutter_boost解决方案，奈何他们的flutter版本还未支持到1.7，集成进来之后各种问题，遂放弃之。

随后我改变思路，采用以native为骨架，flutter为血肉的方式将我这个剪不断理还乱的工程重构了一遍。先抽出来一个继承自`FlutterViewController`的基类`CJViewController`，然后提供一个初始化方法`- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl;`，通过`FlutterViewController`的`setInitialRoute`方法，这样外界传入一个自定义好的路由url，就可以解析到对应的flutter页面，并且可以由native来进行堆栈管理，也可以采用flutter `Navigator`的转场方式跳转到另一个flutter页面。

`flutter`侧：
```
    Map params = {'route':'setting','channel_name':'com.zqtd.cajian/setting'};
    String pStr = convert.jsonEncode(params);
    model.platform.invokeMethod('pushViewControllerWithOpenUrl:', [pStr]);

```

`native`侧：
```
    NSString *openUrl = @"{\"route\":\"login_entrance\",\"channel_name\":\"com.zqtd.cajian/login_entrance\"}";
    CJViewController *nextVc = [[CJViewController alloc] initWithFlutterOpenUrl:openUrl];
    [self.navigationController pushViewController:nextVc
                                         animated:YES];
```

### 如何在native让我集成的插件代码也可以发起网络请求，做一些与用户的反馈交互（弹出提示框hub之类的——Base/里面的代码）

在集成微信登录sdk插件的时候，我并不想只是简单的将微信sdk的方法简单的bridge一遍，然后交给flutter调用。我希望在`sendReq`的同时，我的插件可以处理回调，并一气呵成的完成微信登录的整套操作，包括调用我的网络请求，进行登录提示。但是我不可能把native主工程的代码再在插件pod bridge代码里面再重写一遍，这样即低效又丑陋。我想到了flutter插件的podspec可以依赖其他的pod代码，于是我尝试把我需要用的常用代码（网络请求，弹窗组件，扩展方法等）封装成私有仓库，然后再在插件的podspec里面添加这个依赖，事实证明这样是可行的，由此我便实现了在微信sdk插件里面完成整套微信登录流程。

### 如何进行跨平台通信

这一块也是我初学时比较头疼的，按照官方的思路，传递根视图控制器的`binaryMessenger`注册channel，然后在flutter页面完成对应的注册操作就可以建立通信了。在一开始我采用flutter嵌套native的框架思路时，发现当我登录完成，替换我的keywindow的根视图之后，我的通信就中断了。后来我发现每次当你的flutter路由被native切断，你就需要重新注册你的channel，不然你的消息就无法传递下去。而我实现公共bridge方法的目的是，我可以通过它在任何地方进行双端的通信。于是在我完成页面堆栈的管理之后，在我的基类`CJViewController`初始化方法里，注册这个同名channel，这样不管我是在native页面还是flutter页面，获取到的channel都是同一个。

当我一个flutter页面需要调用一些native操作时，我可以通过创建`CJViewController`的子类，在`- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl;`的openUrl里面指定我的channelName，然后完成一个独立的私有的通道。

`CJViewController.h`

```
/**
 初始化一个flutter 页面，以FlutterVC为容器

 \\******
 需要的JSON字符串格式如下
 {
 'route':'login',
 'channel_name':'com.zqtd.cajian/login',
 'params':{
    'team_id':'298ssdj9238'
    }
 }
 *******\\
 @param openUrl 页面初始化路由和参数
 
 @return 返回VC
 */
- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl;

```

`CJViewController.m`
```
- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl
{
    self = [super initWithProject:nil
                          nibName:nil
                           bundle:nil];
    if(self) {
        [self setInitialRoute:openUrl];
        [self registerChannel];
        
        NSDictionary *params = [NSDictionary cj_dictionary:openUrl];
        
        // 设置回调
        _mc = [FlutterMethodChannel methodChannelWithName:params[@"channel_name"] binaryMessenger:self.engine.binaryMessenger];
        
        __weak typeof(self) wself = self;
        [_mc setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            ZZLog(@"flutter call :%@", call.method);
            SEL callMethod = NSSelectorFromString(call.method);
            if([wself respondsToSelector:callMethod]) {
                [wself performSelector:callMethod
                            withObject:call.arguments
                            afterDelay:0];
            }else {
                ZZLog(@"%@未实现%@", NSStringFromClass(wself.class), call.method);
            }
        }];
        
        // 渲染完成
        [self setFlutterViewDidRenderCallback:^{
//            [_mc invokeMethod:@"会在widget build完成之后调用" arguments:nil];
        }];
        
    }
    return self;
}

/// util 
- (void)registerChannel
{
    __weak typeof(self) weakSelf = self;
    
    _utilChannel = [FlutterMethodChannel
                    methodChannelWithName:@"com.zqtd.cajian/util"
                    binaryMessenger:self.engine.binaryMessenger];
    
    [_utilChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        SEL callMethod = NSSelectorFromString(call.method);
        if([weakSelf respondsToSelector:callMethod])
        {
            [weakSelf performSelector:callMethod
                           withObject:call.arguments
                           afterDelay:0];
        }else {
            [CJUtilBridge bridgeCall:call result:result];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // (@"view did load --- 会在widget build开始之前调用");
    [GeneratedPluginRegistrant registerWithRegistry:self];
}

// 从flutter发来的push新页面操作
- (void)pushViewControllerWithOpenUrl:(NSArray *)params
{
    NSString *openUrl = params.firstObject;
    CJViewController *nextVc = [[CJViewController alloc] initWithFlutterOpenUrl:openUrl];
    [self.navigationController pushViewController:nextVc
                                         animated:YES];
}

// 推出当前页
- (void)popFlutterViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    ZZLog(@"%@ - dealloced!", NSStringFromClass(self.class));
}
```


flutter侧解析路由：

```
Widget _widgetForRoute(String openUrl) {
  debugPrint('FlutterViewController openUrl:' + openUrl);
  dynamic initParams = json.decode(openUrl);

  String route = initParams['route'];
  String cn = initParams['channel_name'];
  Map params = initParams['params'];
  switch (route) {
    case 'login_entrance':
      return new LoginEntrance(channelName: cn);
    case 'mine':
      return new MineWidget(cn);
    case 'contacts':
      return new ContactsWidget(params);
    case 'setting':
      return new SettingWidget(cn);
    default:
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('未找到route为: $route 的页面')),
        ),
      );
  }
}

void main() {
  runApp(_widgetForRoute(ui.window.defaultRouteName));
}
```
