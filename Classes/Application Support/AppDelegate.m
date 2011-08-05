//
//  AppDelegate.m
//  Created by Gregory Combs on 7/22/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>

#import "AppDelegate.h"
#import "SLFRestKitManager.h"


#import "UtilityMethods.h"

#import "TexLegeReachability.h"
#import "TexLegeTheme.h"

#import "GeneralTableViewController.h"

#import "AnalyticsOptInAlertController.h"
#import "LocalyticsSession.h"

#import "SLFLegislator.h"
#import "SLFDistrictMap.h"
#import "CalendarEventsLoader.h"

#import "TVOutManager.h"
#import "MTStatusBarOverlay.h"

#import "StateMetaLoader.h"
#import "StatesListViewController.h"

#import "SLFPersistenceManager.h"
#import "SLFAlertView.h"

@interface AppDelegate (Private)
- (void)runOnEveryAppStart;
- (void)runOnAppQuit;
- (BOOL)isDatabaseResetNeeded;
@end

// user default dictionary keys
NSString * const kAnalyticsAskedForOptInKey = @"HasAskedForOptIn";
NSString * const kAnalyticsSettingsSwitch = @"PermitUseOfAnalytics";
NSString * const kShowedSplashScreenKey = @"HasShownSplashScreen";
NSString * const kSegmentControlPrefKey = @"SegmentControlPrefs";
NSString * const kResetSavedDatabaseKey = @"ResetSavedDatabase";
NSString * const kSupportEmailKey = @"supportEmail";

@implementation AppDelegate

@synthesize tabBarController;
@synthesize appIsQuitting;

@synthesize mainWindow;

@synthesize legislatorMasterVC, committeeMasterVC, linksMasterVC, calendarMasterVC, districtMapMasterVC;
@synthesize billsMasterVC;

+ (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- init {
	if ((self = [super init])) {
		// initialize  to nil
		mainWindow = nil;
		self.appIsQuitting = NO;
		analyticsOptInController = nil;
	}
	return self;
}

- (void)dealloc {
	nice_release(analyticsOptInController);
	
	self.tabBarController = nil;
	self.mainWindow = nil;    
	
	self.linksMasterVC = nil; 
	self.calendarMasterVC = nil;
	self.legislatorMasterVC = nil;
	self.committeeMasterVC = nil;
	self.districtMapMasterVC = nil;
	self.billsMasterVC = nil;

    [super dealloc];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"LOW_MEMORY_WARNING"];
}


#pragma mark -
#pragma mark Data Sources and Main View Controllers


////// IPAD ONLY
- (UISplitViewController *) splitViewController {
	if ([UtilityMethods isIPadDevice]) {
		if (![self.tabBarController.selectedViewController isKindOfClass:[UISplitViewController class]]) {
			RKLogCritical(@"Unexpected navigation controller class in tab bar controller hierarchy, check nib.");
			return nil;
		}
		return (UISplitViewController *)self.tabBarController.selectedViewController;
	}
	return nil;
}


- (UINavigationController *) masterNavigationController {
	if ([UtilityMethods isIPadDevice]) {
		UISplitViewController *split = [self splitViewController];
		if (split && split.viewControllers && [split.viewControllers count])
			return [split.viewControllers objectAtIndex:0];
	}
	else {
		if (![self.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
			RKLogCritical(@"Unexpected view/navigation controller class in tab bar controller hierarchy, check nib.");
		}
		
		UINavigationController *nav = (UINavigationController *)self.tabBarController.selectedViewController;
		return nav;
	}
	return nil;
}

- (UINavigationController *) detailNavigationController {
	if ([UtilityMethods isIPadDevice]) {
		UISplitViewController *split = [self splitViewController];
		if (split && split.viewControllers && [split.viewControllers count]>1)
			return [split.viewControllers objectAtIndex:1];
	}
	else
		return [self masterNavigationController];
	
	return nil;
}

/* Probably works, but ugly and we don't need it.
- (UIViewController *) currentDetailViewController {	
	UINavigationController *nav = [self detailNavigationController];
	NSInteger numVCs = 0;
	if (nav && nav.viewControllers) {
		numVCs = [nav.viewControllers count];
		if ([UtilityMethods isIPadDevice])
			return numVCs ? [nav.viewControllers objectAtIndex:0] : nil;
		else if (numVCs >= 2)	// we're on an iPhone
			return [nav.viewControllers objectAtIndex:1];		// this will give us the second vc in the chain, typicaly a detail vc
	}

	return nil;
}
*/

- (UIViewController *) currentMasterViewController {
	UINavigationController *nav = [self masterNavigationController];
	if (nav && nav.viewControllers && [nav.viewControllers count])
		return [nav.viewControllers objectAtIndex:0];
	return nil;
}

- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)viewController {
	if (!viewController.tabBarItem.enabled)
		return NO;
	
    if (![viewController isEqual:tbc.selectedViewController]) {
        RKLogTrace(@"About to switch tabs, popping to root view controller.");
        UINavigationController *nav = [self detailNavigationController];
        if (nav && [nav.viewControllers count]>1)
            [nav popToRootViewControllerAnimated:YES];
    }
	
	return YES;
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
    if (viewController == theTabBarController.moreNavigationController)
    {
        theTabBarController.moreNavigationController.delegate = self;
    }
	else {
		NSString *vcTitle = nil;
		id masterVC = self.currentMasterViewController;
		if (masterVC)
			vcTitle = NSStringFromClass([masterVC class]);
		if (!vcTitle)
			vcTitle = viewController.tabBarItem.title;
		
		NSDictionary *tabSelectionDict = [NSDictionary dictionaryWithObject:vcTitle forKey:@"Feature"];
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SELECTTAB" attributes:tabSelectionDict];		
	}

    [[SLFPersistenceManager sharedPersistence] savePersistence];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController == self.tabBarController.moreNavigationController)
    {
		NSString *vcTitle = NSStringFromClass([viewController class]);
		if (NO == [vcTitle hasPrefix:@"UIMore"]) {		
			NSDictionary *tabSelectionDict = [NSDictionary dictionaryWithObject:vcTitle forKey:@"Feature"];
			[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SELECTTAB" attributes:tabSelectionDict];
		}
    }
}


- (void) setupViewControllerHierarchy {
		
	NSArray *nibObjects = nil;
	if ([UtilityMethods isIPadDevice]) 
		nibObjects = [[NSBundle mainBundle] loadNibNamed:@"iPadTabBarController" owner:self options:nil];
	else
		nibObjects = [[NSBundle mainBundle] loadNibNamed:@"iPhoneTabBarController" owner:self options:nil];
	
	if (IsEmpty(nibObjects)) {
		RKLogCritical(@"Error loading user interface NIB components! Can't find the nib file and can't continue this charade.");
		exit(0);
	}
	
	NSArray *VCs = [[NSArray alloc] initWithObjects:self.legislatorMasterVC, self.committeeMasterVC, self.districtMapMasterVC,
					self.calendarMasterVC, self.billsMasterVC, self.linksMasterVC, nil];
	
	NSString * recentVCKey = [[SLFPersistenceManager sharedPersistence] persistentViewControllerKey];
    
	NSInteger savedTabSelectionIndex = -1;
    
	NSInteger loopIndex = 0;
	for (GeneralTableViewController *masterVC in VCs) {
		[masterVC configure];
		
		// If we have a preferred VC and we've found it in our array, save it
		if (savedTabSelectionIndex < 0 && recentVCKey && [recentVCKey isEqualToString:NSStringFromClass([masterVC class])]) // we have a saved view controller in mind
			savedTabSelectionIndex = loopIndex;
		loopIndex++;
	}
    
	if (savedTabSelectionIndex < 0 || savedTabSelectionIndex > [VCs count])
		savedTabSelectionIndex = 0;
	
	if ([UtilityMethods isIPadDevice]) {
		NSMutableArray *splitViewControllers = [[NSMutableArray alloc] initWithCapacity:[VCs count]];
		NSInteger index = 0;
		for (GeneralTableViewController * controller in VCs) {
			UISplitViewController * split = [controller splitViewController];
			if (split) {
				// THIS SETS UP THE TAB BAR ITEMS/IMAGES AND SET THE TAG FOR TABBAR_ITEM_TAGS
				split.title = [controller name];
				split.tabBarItem = [[[UITabBarItem alloc] initWithTitle:
									[[controller class] name] image:[[controller class] tabBarImage] tag:index] autorelease];
				[splitViewControllers addObject:split];
			}
			index++;
		}
		[self.tabBarController setViewControllers:splitViewControllers];
		[splitViewControllers release];
	} 
	
    if (self.tabBarController) {
        
        UIViewController * savedTabController = [self.tabBarController.viewControllers objectAtIndex:savedTabSelectionIndex];
        if (!savedTabController || !savedTabController.tabBarItem.enabled) {
            RKLogError(@"Couldn't find a view/navigation controller at index: %d", savedTabSelectionIndex);
            savedTabController = [self.tabBarController.viewControllers objectAtIndex:0];
        }
        else if (self.tabBarController.moreNavigationController) {
            self.tabBarController.moreNavigationController.navigationBar.tintColor = [TexLegeTheme navbar];
        }
        
        // If we have a preexisting saved order for these tabs, let's reorder them
        NSArray *orderedVCs = [[SLFPersistenceManager sharedPersistence] orderedTabsFromPersistence:self.tabBarController.viewControllers];
        if (orderedVCs) {
            self.tabBarController.viewControllers = orderedVCs;
        }
        [self.tabBarController setSelectedViewController:savedTabController];
        
        self.mainWindow.rootViewController = self.tabBarController;
        
    }
	
	nice_release(VCs);
}

- (void)changingReachability:(id)sender {
	if (self.tabBarController) {
		TexLegeReachability *myReach = [TexLegeReachability sharedTexLegeReachability];
		
		for (UITabBarItem *item in [self.tabBarController valueForKeyPath:@"viewControllers.tabBarItem"]) {
			if (item.tag == TAB_BILL || item.tag == TAB_CALENDAR)
				item.enabled = myReach.openstatesConnectionStatus > NotReachable;
			else if (item.tag == TAB_DISTRICTMAP)
				item.enabled = myReach.googleConnectionStatus > NotReachable;
		}
	}
}

- (void)runOnInitialAppStart:(id)sender {	
	
#ifdef DEBUG
    RKLogSetAppLoggingLevel(RKLogLevelDebug);
#else
    RKLogSetAppLoggingLevel(RKLogLevelWarning);
#endif
    
    RKLogDebug(@"Application is starting up");
    
	if(
	   getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")
	   ) {
		for (int loop=0;loop < 6;loop++) {
			RKLogCritical(@"**************** NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!*************");
		}
	}
    	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	[[SLFPersistenceManager sharedPersistence] loadPersistence];
	
	[self setupViewControllerHierarchy];

	[self.mainWindow makeKeyAndVisible];
	[MTStatusBarOverlay sharedMTStatusBarOverlay];

	// register our preference selection data to be archived
    // TODO: really, we need to get this working with the defaults we've already put into Root.strings
    
    NSData *savedTableSelectionData = [[SLFPersistenceManager sharedPersistence] archivableTableSelection];
    
	NSDictionary *savedPrefsDict = [NSDictionary dictionaryWithObjectsAndKeys: 
									savedTableSelectionData,kPersistentSelectionKey,
									[NSNumber numberWithBool:NO], kAnalyticsAskedForOptInKey,
									[NSNumber numberWithBool:YES], kAnalyticsSettingsSwitch,
									[NSNumber numberWithBool:NO], kShowedSplashScreenKey,
									[NSDictionary dictionary], kSegmentControlPrefKey,
									[NSNumber numberWithBool:NO], kResetSavedDatabaseKey,
									[NSString stringWithString:@"support@texlege.com"], kSupportEmailKey,
									version, @"CFBundleVersion",
									nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedPrefsDict];
	
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"CFBundleVersion"];
	[[NSUserDefaults standardUserDefaults] synchronize];
		
	[[LocalyticsSession sharedLocalyticsSession] startSession:LOCALITICS_APIKEY];
	
	[self runOnEveryAppStart];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{		
	RKLogWarning(@"iOS Version: %@", [[UIDevice currentDevice] systemVersion]);
	
	[[TexLegeReachability sharedTexLegeReachability] startCheckingReachability];
	
	// initialize RestKit
	[SLFRestKitManager sharedRestKit];	
	
    // Set up the mainWindow and content view
	UIWindow *localMainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainWindow = localMainWindow;
	[localMainWindow release];
			
	[self runOnInitialAppStart:nil];
		
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[TVOutManager sharedInstance] startTVOut];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[TVOutManager sharedInstance] stopTVOut];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[self runOnEveryAppStart];	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self runOnAppQuit];
}

- (void)applicationWillTerminate:(UIApplication *)application {	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

	[self runOnAppQuit];
}

- (void)runOnEveryAppStart {
        
	self.appIsQuitting = NO;
	
    if ([[StateMetaLoader sharedStateMeta] needsStateSelection])
    {
        /* There surely is a better way to handle this, but without this delay
            the table view orientation is incorrect when runnin on iPads that start up in landscape. */
        RunBlockOnNextLoop(^{
            StatesListViewController *stateVC = [[StatesListViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.mainWindow.rootViewController presentModalViewController:stateVC animated:YES];
            [stateVC release];        
        });
    }
	
	if (![self isDatabaseResetNeeded]) {
		analyticsOptInController = [[AnalyticsOptInAlertController alloc] init];
		if (![analyticsOptInController presentAnalyticsOptInAlertIfNecessary])
			[analyticsOptInController updateOptInFromSettings];
		
	}
	[[LocalyticsSession sharedLocalyticsSession] resume];
 	[[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)runOnAppQuit {
	//[[CalendarEventsLoader sharedCalendarEventsLoader] addAllEventsToiCal:self];		//testing
	
	if (self.appIsQuitting)
		return;                 // We're already quitting, don't go further.
    
	self.appIsQuitting = YES;
		
	if (self.tabBarController) {
        [[SLFPersistenceManager sharedPersistence] saveOrderedTabsToPersistence:self.tabBarController.viewControllers];
	}
	
	// save the drill-down hierarchy of selections to preferences
    [[SLFPersistenceManager sharedPersistence] savePersistence];
	
	[[LocalyticsSession sharedLocalyticsSession] close];
	[[LocalyticsSession sharedLocalyticsSession] upload];	
    
    nice_release(analyticsOptInController);

}

#pragma mark -

- (void)doDataReset:(BOOL)doReset {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kResetSavedDatabaseKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (doReset) {
        [[SLFPersistenceManager sharedPersistence] resetPersistence];
        [[SLFRestKitManager sharedRestKit] resetSavedDatabase:nil]; 
    }
}

- (BOOL) isDatabaseResetNeeded {
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOOL needsReset = [[NSUserDefaults standardUserDefaults] boolForKey:kResetSavedDatabaseKey];
    
    if (needsReset) {
        
        [SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Settings: Reset Data to Factory?", @"AppAlerts", @"Confirmation to delete and reset the app's database.")
                            message:NSLocalizedStringFromTable(@"Are you sure you want to reset the legislative database?  NOTE: The application may quit after this reset.  New data will be downloaded automatically via the Internet during the next app launch.", @"AppAlerts",@"") 
                        cancelTitle:NSLocalizedStringFromTable(@"Cancel",@"StandardUI",@"Cancelling some activity")
                        cancelBlock:^(void) {
                            [self doDataReset:NO];
                        }
                         otherTitle:NSLocalizedStringFromTable(@"Reset", @"StandardUI", @"Reset application settings to defaults")
                         otherBlock:^(void) {
                             [self doDataReset:YES];
                         }];
        
    }
    return needsReset;
}

@end

