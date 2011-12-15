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
#import "SLFAlertView.h"
#import "MKInfoPanel.h"

@interface AppDelegate()
@property (nonatomic,retain) PSStackedViewController *stackController;
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) WatchedBillNotificationManager *billNotifier;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskID;
- (void)setUpOnce;
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
@synthesize stackController = _stackController;
@synthesize navigationController = _navigationController;
@synthesize billNotifier = _billNotifier;
@synthesize backgroundTaskID = _backgroundTaskID;

- (void)dealloc {
    self.window = nil;
    self.billNotifier = nil;
    self.navigationController = nil;
    self.stackController = nil;
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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self setUpReachability];
    [[SLFAnalytics sharedAnalytics] beginTracking];
    [SLFAppearance setupAppearance];
    [SLFRestKitManager sharedRestKit];
    [SLFPersistenceManager sharedPersistence];
    [self setUpURLCache];
    self.billNotifier = [WatchedBillNotificationManager manager];
    [SLFActionPathRegistry sharedRegistry];
    [self setUpViewControllers];
    SLFRunBlockAfterDelay(^{
        [self restoreApplicationState];
    }, .3);
}

- (void)setUpReachability {
    SLFReachable *reachable = [SLFReachable sharedReachable];
    NSSet *hosts = [NSSet setWithObjects:@"openstates.org", @"stateline.org", @"transparencydata.com", @"www.followthemoney.org", @"votesmart.org", nil];
    [reachable watchHostsInSet:hosts];
    SLFRunBlockAfterDelay(^{
        [reachable.localNotification addObserver:self selector:@selector(networkReachabilityChanged:) name:SLFReachableStatusChangedForHostKey object:nil];
    }, 1);
}

- (void)setUpViewControllers {
    if (SLFIsIpad())
        [self setUpViewControllersIpad];
    else
        [self setUpViewControllersIphone];
}

- (void)setUpViewControllersIpad {
    SLFState *foundSavedState = SLFSelectedState();
    StackedMenuViewController* stateMenuVC = [[StackedMenuViewController alloc] initWithState:foundSavedState];
    _stackController = [[SLFStackedViewController alloc] initWithRootViewController:stateMenuVC];
    window.rootViewController = _stackController;
    [window makeKeyAndVisible];
    SLFRunBlockAfterDelay(^{
        // Give the persistent data a chance to materialize, and give time to instantiate the infrastructure.
        if (IsEmpty(SLFSelectedStateID())) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[StatesViewController class] withResource:nil];
            [SLFActionPathNavigator navigateToPath:path skipSaving:YES fromBase:nil popToRoot:NO];
        }
    },.3);
    [stateMenuVC release];
}

- (void)setUpViewControllersIphone {
    StatesViewController* stateListVC = [[StatesViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:stateListVC];    
    window.rootViewController = _navigationController;
    // We should give the persistent data a chance to materialize, and give time to instantiate the infrastructure.
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
    NSString *cachePath = [AFURLCache defaultCachePath];
    AFURLCache *cache = [[AFURLCache alloc] initWithMemoryCapacity:memoryCacheSize diskCapacity:diskCacheSize diskPath:cachePath];
    [NSURLCache setSharedURLCache:cache];
    [cache release];
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
            [MKInfoPanel showPanelInWindow:[UIApplication sharedApplication].keyWindow 
                                      type:MKInfoPanelTypeError 
                                     title:NSLocalizedString(@"Network Failure!",@"") 
                                  subtitle:NSLocalizedString(@"This application requires Internet access to operate.",@"") hideAfter:4];
    });
}

@end
