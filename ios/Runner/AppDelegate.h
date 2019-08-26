#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <WXApi.h>
#import <NIMSDK/NIMSDK.h>

@interface AppDelegate : FlutterAppDelegate <WXApiDelegate, NIMLoginManagerDelegate>

@property (nonatomic, strong) FlutterMethodChannel *utilChannel;

@property (nonatomic, strong) FlutterMethodChannel *nimChannel;

@end
