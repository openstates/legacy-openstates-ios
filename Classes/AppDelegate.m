//
//  AppDelegate.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "AppBarController.h"
#import "SLFStackedViewController.h"
#import "StatesViewController.h"
#import "StackedMenuViewController.h"
#import "StateDetailViewController.h"
#import "SLFRestKitManager.h"
#import "SLFAppearance.h"
#import "SDURLCache.h"
#import "SLFReachable.h"
#import "WatchedBillNotificationManager.h"
#import "SLFAlertView.h"
#import "MTInfoPanel.h"
#import "SLFEventsManager.h"

@interface AppDelegate()
@property (nonatomic,retain) AppBarController *appBarController;
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) WatchedBillNotificationManager *billNotifier;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskID;
- (void)setUpOnce;
- (void)setUpBackgroundTasks;
- (void)setUpReachability;
- (void)setUpViewControllers;
- (void)setUpViewControllersIpad;
- (void)setUpViewControllersIphone;
- (void)restoreApplicationState;
- (void)saveApplicationState;
- (void)setUpURLCache;
- (void)networkReachabilityChanged:(NSNotification *)notification;
@end

@implementation AppDelegate
@synthesize window;
@synthesize appBarController = _appBarController;
@synthesize stackedViewController = _stackedViewController;
@synthesize navigationController = _navigationController;
@synthesize billNotifier = _billNotifier;
@synthesize backgroundTaskID = _backgroundTaskID;

- (void)dealloc {
    self.window = nil;
    self.billNotifier = nil;
    self.navigationController = nil;
    self.appBarController = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setUpOnce];
    return YES;
}

- (void)setUpOnce {
#ifdef DEBUG
    RKLogSetAppLoggingLevel(RKLogLevelDebug);
#else
    RKLogSetAppLoggingLevel(RKLogLevelWarning);
#endif
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self performSelectorInBackground:@selector(setUpBackgroundTasks) withObject:nil];
    [SLFAppearance setupAppearance];
    [SLFRestKitManager sharedRestKit];
    [SLFPersistenceManager sharedPersistence];
    self.billNotifier = [WatchedBillNotificationManager manager];
    [SLFActionPathRegistry sharedRegistry];
    [self setUpViewControllers];
    
    if( getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled") ) {
        [MTInfoPanel showPanelInWindow:self.window type:MTInfoPanelTypeWarning title:@"Debug Features!" subtitle:@"NSZombieEnabled and/or NSAutoreleaseFreedObject debug features are turned on. Turn them off before delivery." hideAfter:5.f];
        RKLogCritical(@"**************** NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!*************");
    }
         
    __block __typeof__(self) bself = self;
    SLFRunBlockAfterDelay(^{
        [bself restoreApplicationState];
    }, .3);
}

- (void)setUpBackgroundTasks {
    [self setUpReachability];
    [self setUpURLCache];
    [SLFEventsManager sharedManager];
    [[SLFAnalytics sharedAnalytics] beginTracking];
}

- (void)setUpReachability {
    SLFReachable *reachable = [SLFReachable sharedReachable];
    NSSet *hosts = [NSSet setWithObjects:@"openstates.org", @"assets.openstates.org", @"stateline.org", @"transparencydata.com", @"www.followthemoney.org", @"votesmart.org", nil];
    [reachable watchHostsInSet:hosts];
    __block __typeof__(self) bself = self;
    SLFRunBlockAfterDelay(^{
        [reachable.localNotification addObserver:bself selector:@selector(networkReachabilityChanged:) name:SLFReachableStatusChangedForHostKey object:nil];
    }, 1);
}

- (void)setUpViewControllers {
    if (SLFIsIpad())
        [self setUpViewControllersIpad];
    else
        [self setUpViewControllersIphone];
}

- (void)setUpViewControllersIpad {
    _appBarController = [[AppBarController alloc] initWithNibName:nil bundle:nil];
    window.rootViewController = _appBarController;
    [window makeKeyAndVisible];
}

- (SLFStackedViewController *)stackedViewController {
    if (_appBarController && _appBarController.stackedViewController)
        return _appBarController.stackedViewController;
    return nil;
}

- (void)setUpViewControllersIphone {
    StatesViewController* stateListVC = [[StatesViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:stateListVC]; 
    window.rootViewController = _navigationController;
    if (!SLFIsIOS5OrGreater())
        _navigationController.navigationBar.tintColor = [SLFAppearance cellSecondaryTextColor];
    SLFState *foundSavedState = SLFSelectedState();
    if (foundSavedState) {
        StateDetailViewController *menu = [[StateDetailViewController alloc] initWithState:foundSavedState];
        [_navigationController pushViewController:menu animated:NO];
        [menu release];
    }
    [window makeKeyAndVisible];
    [stateListVC release];
}

- (void)setUpURLCache {
    const NSUInteger memoryCacheSize = 1024*1024*4;   // 4MB mem cache
    const NSUInteger diskCacheSize = 1024*1024*15;    // 15MB disk cache
    NSString *cachePath = [SDURLCache defaultCachePath];
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:memoryCacheSize diskCapacity:diskCacheSize diskPath:cachePath];
    [NSURLCache setSharedURLCache:urlCache];
    [urlCache release];
}

- (void)restoreApplicationState {
    NSString *actionPath = SLFCurrentActionPath();
    if (IsEmpty(actionPath))
        return;
    [SLFActionPathNavigator navigateToPath:actionPath skipSaving:YES fromBase:nil popToRoot:NO];
}

- (void)saveApplicationState {
    [[SLFPersistenceManager sharedPersistence] savePersistence];
}
    
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    RKLogCritical(@"Received memory warning!");
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
    [SLFActionPathNavigator cancelPreviousPerformRequestsWithTarget:[SLFActionPathNavigator class]];
    [SLFActionPathNavigator navigateToPath:path skipSaving:YES fromBase:nil popToRoot:NO];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[SLFAnalytics sharedAnalytics] resumeTracking];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[SLFAnalytics sharedAnalytics] pauseTracking];
    [self saveApplicationState];
    
#ifdef TEST_LOCAL_NOTIFICATIONS
    __block __typeof__(self) bself = self;
    _backgroundTaskID = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:bself.backgroundTaskID];
            bself.backgroundTaskID = UIBackgroundTaskInvalid;
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
    [SLFAlertView showWithTitle:NSLocalizedString(@"Notification",@"") message:notification.alertBody cancelTitle:NSLocalizedString(@"Dismiss",@"") cancelBlock:nil otherTitle:notification.alertAction otherBlock:^{
        NSString *actionPath = [notification.userInfo valueForKey:@"ActionPath"];
        if (!IsEmpty(actionPath)) {
            [SLFActionPathNavigator cancelPreviousPerformRequestsWithTarget:[SLFActionPathNavigator class]];
            [SLFActionPathNavigator navigateToPath:actionPath skipSaving:YES fromBase:nil popToRoot:NO];
        }
    }];
}
    
- (void)networkReachabilityChanged:(NSNotification *)notification {
    SLFRunBlockInNextRunLoop(^{
        if (!SLFIsReachableAddressNoAlert(@"http://openstates.org"))
            [MTInfoPanel showPanelInWindow:self.window type:MTInfoPanelTypeError title:NSLocalizedString(@"Network Failure!",@"") subtitle:NSLocalizedString(@"This application requires Internet access to operate.",@"") hideAfter:4.f];
    });
}

@end
