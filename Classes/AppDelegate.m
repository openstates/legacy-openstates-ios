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
#import "StackedMenuViewController.h"
#import "StateDetailViewController.h"
#import "SLFRestKitManager.h"
#import "SLFAppearance.h"
#import "AFURLCache.h"
#import "SLFReachable.h"

@interface AppDelegate()
@property (nonatomic, retain) PSStackedViewController *stackController;
- (void)setUpOnce;
- (void)setUpReachability;
- (void)setUpViewControllers;
- (void)setUpIpadViewControllers;
- (void)setUpIphoneViewControllers;
- (void)saveApplicationState;
@end

@implementation AppDelegate
@synthesize window;
@synthesize stackController = stackController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setUpOnce];
    return YES;
}

- (void)setUpOnce {
    RKLogSetAppLoggingLevel(RKLogLevelDebug);
    if( getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled") ) {
        for (int loop=0;loop < 6;loop++) {
            RKLogCritical(@"**************** NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!*************");
        }
    }
    [self setUpReachability];
    [SLFAppearance setupAppearance];
    [SLFRestKitManager sharedRestKit];
    [[SLFPersistenceManager sharedPersistence] loadPersistence:nil];
    [NSURLCache setSharedURLCache:[[[AFURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                          diskCapacity:1024*1024*5 // 5MB disk cache
                                                              diskPath:[AFURLCache defaultCachePath]] autorelease]];    
    [self setUpViewControllers];
}

- (void)setUpReachability {
    SLFReachable *reachable = [SLFReachable sharedReachable];
    NSSet *hosts = [NSSet setWithObjects:@"openstates.org", @"stateline.org", @"transparencydata.com", @"www.followthemoney.org", @"votesmart.org", nil];
    [reachable watchHostsInSet:hosts];
}

- (void)setUpViewControllers {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    if (PSIsIpad())
        [self setUpIpadViewControllers];
    else
        [self setUpIphoneViewControllers];
}

- (void)setUpIpadViewControllers {
    SLFState *selectedState = SLFSelectedState();
    StackedMenuViewController* stateMenuVC = [[StackedMenuViewController alloc] initWithState:selectedState];
    PSStackedViewController *stackedController = [[PSStackedViewController alloc] initWithRootViewController:stateMenuVC];
    stackedController.leftInset = STACKED_MENU_INSET;
    stackedController.largeLeftInset = STACKED_MENU_WIDTH;
    self.stackController = stackedController;
    window.rootViewController = stackedController;
    [window makeKeyAndVisible];
    if (!selectedState) {
            // Ugly yes, but this brief delay fixes issues with view orientation on iPads when starting up in landscape.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [stateMenuVC changeSelectedState:nil];
       }];

    }
    [stateMenuVC release];
    [stackedController release];
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
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)dealloc {
    self.window = nil;
    [super dealloc];
}

#pragma - Private Convenience Methods

- (void)saveApplicationState {
    [[SLFPersistenceManager sharedPersistence] savePersistence];
}
    

@end
