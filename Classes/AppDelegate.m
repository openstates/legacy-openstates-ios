//
//  AppDelegate.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "AppDelegate.h"
#import "StatesViewController.h"
#import "StateDetailViewController.h"
#import "SLFRestKitManager.h"
#import "SLFAppearance.h"

@interface AppDelegate()
- (void)setUpOnce;
- (void)setUpViewControllers;
- (void)setUpIpadViewControllers;
- (void)setUpIphoneViewControllers;
- (void)saveApplicationState;
@end

@implementation AppDelegate
@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setUpOnce];
    return YES;
}

- (void)setUpOnce {
    RKLogSetAppLoggingLevel(RKLogLevelDebug);
    [SLFAppearance setupTheme];
    [SLFRestKitManager sharedRestKit];
    [self setUpViewControllers];
}

- (void)setUpViewControllers {
    if (PSIsIpad())
        [self setUpIpadViewControllers];
    else
        [self setUpIphoneViewControllers];
}

- (void)setUpIpadViewControllers {
    SLFState *selectedState = SLFSelectedState();
    StateDetailViewController* stateMenuVC = [[StateDetailViewController alloc] initWithState:selectedState];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:stateMenuVC];    
    window.rootViewController = navController;
    [window makeKeyAndVisible];
    if (!selectedState) {
        StatesViewController* stateListVC = [[StatesViewController alloc] init];
        UINavigationController* tempNavController = [[UINavigationController alloc] initWithRootViewController:stateListVC];    
        stateListVC.stateMenuDelegate = stateMenuVC;
        [stateMenuVC presentModalViewController:tempNavController animated:YES];
        [stateListVC release];
        [tempNavController release];
    }
    [stateMenuVC release];
    [navController release];    
}

- (void)setUpIphoneViewControllers {
    SLFState *selectedState = SLFSelectedState();
    StatesViewController* stateListVC = [[StatesViewController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:stateListVC];    
    window.rootViewController = navController;
    if (selectedState) {
        StateDetailViewController* stateMenuVC = [[StateDetailViewController alloc] initWithState:selectedState];
        [navController pushViewController:stateMenuVC animated:NO];
        [stateMenuVC release];
    }
    [window makeKeyAndVisible];
    [stateListVC release];
    [navController release];    
}

/*
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
+ (void)initialize {
    if ([self class] == [AppDelegate class]) {
        NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"selectedState"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:settings];
    }
}
*/
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveApplicationState];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveApplicationState];
}

- (void)dealloc {
    self.window = nil;
    [super dealloc];
}

#pragma - Private Convenience Methods

- (void)saveApplicationState {
    [[NSUserDefaults standardUserDefaults] synchronize];
}
    

@end
