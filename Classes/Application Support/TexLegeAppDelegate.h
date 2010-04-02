/*

File: TexLegeAppDelegate.h
Abstract: Application delegate that sets up the application.

Version: 1.7

*/

#import <UIKit/UIKit.h>

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate> {

    UIWindow *portraitWindow;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UIWindow *portraitWindow;


@end
