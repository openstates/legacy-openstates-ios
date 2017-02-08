//
//  AppDelegate.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <SLFRestKit/RestKit.h>
#import "AppBarController.h"
#import "SLFStackedViewController.h"
#import "StatesViewController.h"
#import "StackedMenuViewController.h"
#import "StateDetailViewController.h"
#import "SLFRestKitManager.h"
#import "SLFAppearance.h"
#import "SLFReachable.h"
#import "WatchedBillNotificationManager.h"
#import "SLFAlertView.h"
#import "SLFEventsManager.h"
#import "SLFPersistenceManager.h"
#import "SLFActionPathNavigator.h"
#import "SLFAnalytics.h"
#import "SLToastManager+OpenStates.h"
#import "SLFLog.h"

@interface AppDelegate()
@property (nonatomic,weak) SLFStackedViewController *stackedViewController;
@property (nonatomic,strong) AppBarController *appBarController;
@property (nonatomic,strong) UINavigationController *navigationController;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskID;
@property (nonatomic,strong) SLToastManager *toastMgr;

- (void)setUpOnce;
- (void)setUpBackgroundTasks;
- (void)setUpReachability;
- (void)setUpViewControllers;
- (void)setUpViewControllersIpad;
- (void)setUpViewControllersIphone;
- (void)restoreApplicationState;
- (void)saveApplicationState;
- (void)networkReachabilityChanged:(NSNotification *)notification;
@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    [Fabric sharedSDK].debug = YES;
#endif

    [Fabric with:@[[Crashlytics class],[Answers class]]];
    [Answers logCustomEventWithName:@"AppStart" customAttributes:nil];

    [self setUpGoogleAnalytics];

    [self setUpOnce];

    return YES;
}

- (void)setUpOnce
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self performSelectorInBackground:@selector(setUpBackgroundTasks) withObject:nil];
    [SLFAppearance setupAppearance];
    [SLFRestKitManager sharedRestKit];
    [SLFPersistenceManager sharedPersistence];
    [[WatchedBillNotificationManager manager] resetStatusNotifications:nil];
    [SLFActionPathRegistry sharedRegistry];
    [self setUpViewControllers];
    
    __weak __typeof__(self) wSelf = self;
    SLFRunBlockAfterDelay(^{
        [wSelf restoreApplicationState];
    }, .3);
}

- (void)runOnEveryAppStart:(UIApplication *)application
{
    SLToastManager *toastMgr = [[SLToastManager alloc] initWithManagerId:@"OpenStatesRootToast" parentView:self.window];
    toastMgr.statusBarFrame = application.statusBarFrame;
    _toastMgr = toastMgr;
    [SLToastManager opstSetSharedManager:toastMgr];

}

- (void)setUpBackgroundTasks {
    @autoreleasepool {
        [self setUpReachability];
        [SLFEventsManager sharedManager];
        [[SLFAnalytics sharedAnalytics] beginTracking];
    }
}

- (void)setUpReachability {
    SLFReachable *reachable = [SLFReachable sharedReachable];
    NSSet *hosts = [NSSet setWithObjects:@"openstates.org", @"static.openstates.org", @"stateline.org", @"transparencydata.com", @"www.followthemoney.org", @"votesmart.org", nil];
    [reachable watchHostsInSet:hosts];
    __weak __typeof__(self) wSelf = self;
    SLFRunBlockAfterDelay(^{
        [reachable.localNotification addObserver:wSelf selector:@selector(networkReachabilityChanged:) name:SLFReachableStatusChangedForHostKey object:nil];
    }, 1);
}

- (void)setUpGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 30;

    // Initialize tracker.
    id tracker = nil;

#if CONFIGURATION_Release
    tracker = [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsIdRelease];
#endif

#if CONFIGURATION_Debug
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#endif

    if (tracker) {
        NSDictionary *dict = [[GAIDictionaryBuilder createEventWithCategory:@"UX" action:@"appstart" label:nil value:nil] build];
        [dict setValue:@"start" forKey:kGAISessionControl];
        [tracker send:dict];
    }
}

- (void)setUpViewControllers {
    if (SLFIsIpad())
        [self setUpViewControllersIpad];
    else
        [self setUpViewControllersIphone];
}

- (void)setUpViewControllersIpad {
    _appBarController = [[AppBarController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = _appBarController;
    [self.window makeKeyAndVisible];
}

- (SLFStackedViewController *)stackedViewController {
    if (_appBarController && _appBarController.stackedViewController)
        return _appBarController.stackedViewController;
    return nil;
}

- (void)setUpViewControllersIphone {
    StatesViewController* stateListVC = [[StatesViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:stateListVC]; 
    self.window.rootViewController = _navigationController;
    if (!SLFIsIOS5OrGreater())
        _navigationController.navigationBar.tintColor = [SLFAppearance cellSecondaryTextColor];
    SLFState *foundSavedState = SLFSelectedState();
    if (foundSavedState) {
        StateDetailViewController *menu = [[StateDetailViewController alloc] initWithState:foundSavedState];
        [_navigationController pushViewController:menu animated:NO];
    }
    [self.window makeKeyAndVisible];
}

- (void)restoreApplicationState {
    NSString *actionPath = SLFCurrentActionPath();
    if (!SLFTypeNonEmptyStringOrNil(actionPath))
        return;
    [[WatchedBillNotificationManager manager] resetStatusNotifications:nil];
    [SLFActionPathNavigator navigateToPath:actionPath skipSaving:YES fromBase:nil popToRoot:NO];
}

- (void)saveApplicationState {
    [[SLFPersistenceManager sharedPersistence] savePersistence];
}
    
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    os_log_error([SLFLog common], "Received low-memory warning");
    [[SLFAnalytics sharedAnalytics] tagEvent:@"MEMORY_WARNING" attributes:[NSDictionary dictionaryWithObject:@"APP_DEV" forKey:@"category"]];
    [[SLFAnalytics sharedAnalytics] endTracking];
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024]; // a more conservative value, 1MB
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveApplicationState];
    [[SLFAnalytics sharedAnalytics] endTracking];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url)
        return NO;
    NSString *path = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ( NO == [path hasPrefix:@"slfos:"] )
        return NO;
    [[WatchedBillNotificationManager manager] resetStatusNotifications:nil];
    [SLFActionPathNavigator cancelPreviousPerformRequestsWithTarget:[SLFActionPathNavigator class]];
    [SLFActionPathNavigator navigateToPath:path skipSaving:YES fromBase:nil popToRoot:NO];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[WatchedBillNotificationManager manager] resetStatusNotifications:nil];
    [[SLFAnalytics sharedAnalytics] resumeTracking];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[SLFAnalytics sharedAnalytics] pauseTracking];
    [self saveApplicationState];
    
#ifdef TEST_LOCAL_NOTIFICATIONS
    __weak __typeof__(self) wSelf = self;
    _backgroundTaskID = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:bself.backgroundTaskID];
            wSelf.backgroundTaskID = UIBackgroundTaskInvalid;
        });
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval now = [application backgroundTimeRemaining];
        NSCondition *waiter = [[NSCondition alloc] init];
        [waiter lock];
        while (now > 10.0) {
            [waiter waitUntilDate:[NSDate dateWithTimeInterval:SLF_HOURS_TO_SECONDS(.5) sinceDate:[NSDate date]]];
            now = [application backgroundTimeRemaining];
            [bself.billNotifier checkBillsStatus:bself];
            NSLog(@"Something happening, time remaining = %f seconds", now);
        }
        [waiter unlock];
        [waiter release];
        [application endBackgroundTask:bself.backgroundTaskID];
        bself.backgroundTaskID = UIBackgroundTaskInvalid;
    });
#endif
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    BOOL foreground = (application.applicationState == UIApplicationStateActive);
    if (!foreground)
        return;
    if (!notification)
        return;
    [SLFAlertView showWithTitle:NSLocalizedString(@"Notification", nil) message:notification.alertBody cancelTitle:NSLocalizedString(@"Dismiss", nil) cancelBlock:nil otherTitle:notification.alertAction otherBlock:^{
        NSString *actionPath = SLTypeStringOrNil(SLTypeDictionaryOrNil(notification.userInfo)[@"ActionPath"]);
        if (actionPath)
        {
            [SLFActionPathNavigator cancelPreviousPerformRequestsWithTarget:[SLFActionPathNavigator class]];
            [SLFActionPathNavigator navigateToPath:actionPath skipSaving:YES fromBase:nil popToRoot:NO];
        }
    }];
}
    
- (void)networkReachabilityChanged:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (!SLFIsReachableAddressNoAlert(@"http://openstates.org"))
        {
            [[SLToastManager opstSharedManager] addToastWithIdentifier:@"OpenStates-Unreachable-Host"
                                                                  type:SLToastTypeError
                                                                 title:NSLocalizedString(@"Network Failure!", nil)
                                                              subtitle:NSLocalizedString(@"This application requires Internet access to operate.", nil)
                                                                 image:nil
                                                              duration:4];
        }
    }];
}

@end
