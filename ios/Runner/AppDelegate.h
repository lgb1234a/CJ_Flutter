#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <NIMSDK/NIMSDK.h>

@interface AppDelegate : FlutterAppDelegate <NIMLoginManagerDelegate>

@property (nonatomic, strong) UITabBarController *tabbar;

@end
