/**
 *  Created by chenyn on 2019-07-26
 *  会话页flutter封装
 */


#import "FlutterSessionViewController.h"
#import "CJSessionViewController.h"

@interface FlutterSessionViewController ()<CJSessionDelegate>

@end

@implementation FlutterSessionViewController
{
    int64_t _viewId;
    FlutterMethodChannel *_channel;
    CJSessionViewController *_viewController;
}

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
{
    if([super init]) {
        // 获取参数
        NSDictionary *dic = args;
        NIMSession *session = [NIMSession session:dic[@"session_id"]
                                              type:[dic[@"session_type"] integerValue]] ;
        _viewController = [[CJSessionViewController alloc] initWithSession:session];
        _viewController.delegate = self;
        
        _viewId = viewId;
        NSString *channelName = [NSString stringWithFormat:@"plugins/session_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
    }
    return self;
}

-(UIView *)view{
    return _viewController.view;
}

-(void)onMethodCall:(FlutterMethodCall*)call
             result:(FlutterResult)result
{
    if ([[call method] isEqualToString:@"start"]) {
        
    }else
        if ([[call method] isEqualToString:@"stop"]){
            
        }
        else {
            result(FlutterMethodNotImplemented);
        }
}


#pragma mark --- CJSessionDelegate


@end

@implementation FlutterSessionViewControllerFactory

{
    NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id)args
{
    
    FlutterSessionViewController *v = [[FlutterSessionViewController
                                            alloc]
                                           initWithWithFrame:frame
                                           viewIdentifier:viewId
                                           arguments:args
                                           binaryMessenger:_messenger];
    
    return v;
    
}

@end
