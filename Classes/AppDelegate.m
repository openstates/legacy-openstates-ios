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
#import "WatchedBillNotificationManager.h"
#import "SLFActionPathNavigator.h"

@interface AppDelegate()
@property (nonatomic,retain) PSStackedViewController *stackController;
@property (nonatomic,retain) WatchedBillNotificationManager *billNotifier;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskID;
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
@synthesize billNotifier = _billNotifier;
@synthesize backgroundTaskID = _backgroundTaskID;

- (void)dealloc {
    self.window = nil;
    self.billNotifier = nil;
    [super dealloc];
}

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
    [[SLFAnalytics sharedAnalytics] beginTracking];
    [SLFAppearance setupAppearance];
    [SLFRestKitManager sharedRestKit];
    [[SLFPersistenceManager sharedPersistence] loadPersistence:nil];
    self.billNotifier = [WatchedBillNotificationManager manager];
    [NSURLCache setSharedURLCache:[[[AFURLCache alloc] initWithMemoryCapacity:1024*1024*4   // 4MB mem cache
                                                          diskCapacity:1024*1024*15 // 15MB disk cache
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
    if (SLFIsIpad())
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
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
+ (void)initialize {
    if ([self class] == [AppDelegate class]) {
        NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"selectedState"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:settings];
    }
}
*/
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[SLFAnalytics sharedAnalytics] resumeTracking];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[SLFAnalytics sharedAnalytics] pauseTracking];
    [self saveApplicationState];
    
    _backgroundTaskID = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:self.backgroundTaskID];
            self.backgroundTaskID = UIBackgroundTaskInvalid;
        });
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval now = [application backgroundTimeRemaining];
        NSCondition *waiter = [[NSCondition alloc] init];
        [waiter lock];
        while (now > 10.0) {
            [waiter waitUntilDate:[NSDate dateWithTimeInterval:SLF_HOURS_TO_SECONDS(.5) sinceDate:[NSDate date]]];
            now = [application backgroundTimeRemaining];
            [self.billNotifier checkBillsStatus:self];
            NSLog(@"Something happening, time remaining = %f seconds", now);
        }
        [waiter unlock];
        [waiter release];

        [application endBackgroundTask:self.backgroundTaskID];
        self.backgroundTaskID = UIBackgroundTaskInvalid;
    });
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveApplicationState];
    [[SLFAnalytics sharedAnalytics] endTracking];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    BOOL foreground = (application.applicationState == UIApplicationStateActive);
    if (!foreground)
        return;
    NSString *actionPath = [notification.userInfo valueForKey:@"ActionPath"];
    if (!IsEmpty(actionPath))
        [SLFActionPathNavigator navigateToPath:actionPath];
}

#pragma - Private Convenience Methods

- (void)saveApplicationState {
    [[SLFPersistenceManager sharedPersistence] savePersistence];
}
    

@end
