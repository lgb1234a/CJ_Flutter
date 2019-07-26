/**
 *  Created by chenyn on 2019-07-26
 *  会话列表页flutter封装
 */

#import "FlutterSessionListViewController.h"
#import "CJSessionListViewController.h"

@interface FlutterSessionListViewController ()

@end

@implementation FlutterSessionListViewController
{
    int64_t _viewId;
    FlutterMethodChannel *_channel;
    CJSessionListViewController *_viewController;
}

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
{
    if([super init]) {
        NSDictionary *dic = args;
        // 获取参数
        _viewController = [[CJSessionListViewController alloc] init];
        
        
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"plugins/session_list_%lld", viewId];
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


@end

@interface FlutterSessionListViewControllerFactory ()

@end


@implementation FlutterSessionListViewControllerFactory
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
    
    FlutterSessionListViewController *v = [[FlutterSessionListViewController
                                            alloc]
                                           initWithWithFrame:frame
                                           viewIdentifier:viewId
                                           arguments:args
                                           binaryMessenger:_messenger];
    
    return v;
    
}


@end
