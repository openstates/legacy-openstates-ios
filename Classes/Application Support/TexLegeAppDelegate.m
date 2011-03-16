//
//  TexLegeAppDelegate.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//


#import "TexLegeAppDelegate.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "PartisanIndexStats.h"

#import "TexLegeReachability.h"
#import "TexLegeTheme.h"

#import "GeneralTableViewController.h"
#import "TableDataSourceProtocol.h"

#import "AnalyticsOptInAlertController.h"
#import "LocalyticsSession.h"

#import "LegislatorObj.h"
#import "DistrictMapObj.h"
#import "DataModelUpdateManager.h"

#import <RestKit/RestKit.h>

#import "TVOutManager.h"

@interface TexLegeAppDelegate (Private)
- (void)runOnEveryAppStart;
- (void)runOnAppQuit;
- (void)setupFeatures;
- (void)restoreArchivableSavedTableSelection;
- (NSData *)archivableSavedTableSelection;
- (void)resetSavedTableSelection:(id)sender;
- (BOOL)isDatabaseResetNeeded;
@end

// user default dictionary keys
NSString * const kSavedTabOrderKey = @"SavedTabOrderVersion2";
NSString * const kRestoreSelectionKey = @"RestoreSelection";
NSString * const kAnalyticsAskedForOptInKey = @"HasAskedForOptIn";
NSString * const kAnalyticsSettingsSwitch = @"PermitUseOfAnalytics";
NSString * const kShowedSplashScreenKey = @"HasShownSplashScreen";
NSString * const kSegmentControlPrefKey = @"SegmentControlPrefs";
NSString * const kResetChartCacheKey = @"ResetChartCache";
NSString * const kResetSavedDatabaseKey = @"ResetSavedDatabase";

NSUInteger kNumMaxTabs = 11;
NSInteger kNoSelection = -1;

@implementation TexLegeAppDelegate

@synthesize tabBarController;
@synthesize savedTableSelection, appIsQuitting;

@synthesize mainWindow;
@synthesize dataUpdater;

@synthesize legislatorMasterVC, committeeMasterVC, capitolMapsMasterVC, linksMasterVC, calendarMasterVC, districtMapMasterVC;
@synthesize billsMasterVC;

+ (TexLegeAppDelegate *)appDelegate {
	return (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- init {
	if (self = [super init]) {
		// initialize  to nil
		mainWindow = nil;
		self.appIsQuitting = NO;
		self.savedTableSelection = [NSMutableDictionary dictionary];
		self.dataUpdater = [[[DataModelUpdateManager alloc] init] autorelease];
		analyticsOptInController = nil;
	}
	return self;
}

- (void)dealloc {
	if (analyticsOptInController)
		[analyticsOptInController release], analyticsOptInController = nil;
	
	self.savedTableSelection = nil;
	self.tabBarController = nil;
	self.mainWindow = nil;    
	
	self.capitolMapsMasterVC = nil;
	self.linksMasterVC = nil; 
	self.calendarMasterVC = nil;
	self.legislatorMasterVC = nil;
	self.committeeMasterVC = nil;
	self.districtMapMasterVC = nil;
	self.billsMasterVC = nil;

	self.dataUpdater = nil;
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
			debug_NSLog(@"Unexpected navigation controller class in tab bar controller hierarchy, check nib.");
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
			debug_NSLog(@"Unexpected view/navigation controller class in tab bar controller hierarchy, check nib.");
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

/* Probably works, but ugly as hell and we don't need it.
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


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	if (!viewController.tabBarItem.enabled)
		return NO;
	
	if (/*![UtilityMethods isIPadDevice]*/1) {
		if (![viewController isEqual:self.tabBarController.selectedViewController]) {
			//debug_NSLog(@"About to switch tabs, popping to root view controller.");
			UINavigationController *nav = [self detailNavigationController];
			if (nav && [nav.viewControllers count]>1)
				[nav popToRootViewControllerAnimated:YES];
		}
	}
	
	return YES;
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
	NSString *vcTitle = @"More";
	id masterVC = self.currentMasterViewController;
	if (masterVC && [masterVC respondsToSelector:@selector(viewControllerKey)])
		vcTitle = [masterVC performSelector:@selector(viewControllerKey)];
	if (!vcTitle)
		vcTitle = viewController.tabBarItem.title;
	
	NSDictionary *tabSelectionDict = [NSDictionary dictionaryWithObject:vcTitle forKey:@"Feature"];
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SELECTTAB" attributes:tabSelectionDict];
		
	[[NSUserDefaults standardUserDefaults] setObject:[self archivableSavedTableSelection] forKey:kRestoreSelectionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)setTabOrderIfSaved {
	[[NSUserDefaults standardUserDefaults] synchronize];	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedOrder = [defaults arrayForKey:kSavedTabOrderKey];
	NSMutableArray *orderedTabs = [NSMutableArray arrayWithCapacity:[self.tabBarController.viewControllers count]];
	NSInteger foundVCs = 0;
	if (savedOrder && [savedOrder count] > 0 ) {
		for (NSInteger i = 0; i < [savedOrder count]; i++){
			for (UIViewController *aController in self.tabBarController.viewControllers) {
				if ([aController.tabBarItem.title isEqualToString:[savedOrder objectAtIndex:i]]) {
					[orderedTabs addObject:aController];
					foundVCs++;
				}
			}
		}
		if (foundVCs < [self.tabBarController.viewControllers count]) // we've got more now than we used to
			[defaults removeObjectForKey:kSavedTabOrderKey];
		else
			tabBarController.viewControllers = orderedTabs;
	}
}

- (void) setupFeatures {
	
	[PartisanIndexStats sharedPartisanIndexStats];
	
	NSArray *nibObjects = nil;
	if ([UtilityMethods isIPadDevice]) 
		nibObjects = [[NSBundle mainBundle] loadNibNamed:@"iPadTabBarController" owner:self options:nil];
	else
		nibObjects = [[NSBundle mainBundle] loadNibNamed:@"iPhoneTabBarController" owner:self options:nil];
	
	if (!nibObjects || [nibObjects count] == 0) {
		debug_NSLog(@"Error loading user interface NIB components! Can't find the nib file and can't continue this charade.");
		exit(0);
	}
	
	NSArray *VCs = [[NSArray alloc] initWithObjects:self.legislatorMasterVC, self.committeeMasterVC, self.districtMapMasterVC,
					self.calendarMasterVC, self.billsMasterVC, self.capitolMapsMasterVC, self.linksMasterVC, nil];
	
	NSString * tempVCKey = [self.savedTableSelection objectForKey:@"viewController"];
	NSInteger savedTabSelectionIndex = -1;
	NSInteger loopIndex = 0;
	for (GeneralTableViewController *masterVC in VCs) {
		[masterVC configure];
		
		// If we have a preferred VC and we've found it in our array, save it
		if (savedTabSelectionIndex < 0 && tempVCKey && [tempVCKey isEqualToString:[masterVC viewControllerKey]]) // we have a saved view controller in mind
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
				split.title = [[controller dataSource] name];
				split.tabBarItem = [[[UITabBarItem alloc] initWithTitle:
									[[controller dataSource] name] image:[[controller dataSource] tabBarImage] tag:index] autorelease];
				[splitViewControllers addObject:split];
			}
			index++;
		}
		[self.tabBarController setViewControllers:splitViewControllers];
		[splitViewControllers release];
	} 

	for (GeneralTableViewController *controller in VCs) {
		/*if ([[controller viewControllerKey] isEqualToString:@"CommitteeMasterViewController"]) {
			NSError *error = nil;
			NSInteger count = [CommitteeObj count:&error];
			if (error || count == 0)
				controller.navigationController.tabBarItem.enabled = NO;
		}*/	
		if ([[controller viewControllerKey] isEqualToString:@"BillsMasterViewController"]) {
			if (![TexLegeReachability canReachHostWithURL:[NSURL URLWithString:@"http://openstates.sunlightlabs.com"] alert:NO])
				controller.navigationController.tabBarItem.enabled = NO;
		}
		
	}
	[VCs release];
	
	UIViewController * savedTabController = [self.tabBarController.viewControllers objectAtIndex:savedTabSelectionIndex];
	if (!savedTabController || !savedTabController.tabBarItem.enabled) {
		debug_NSLog (@"Couldn't find a view/navigation controller at index: %d", savedTabSelectionIndex);
		savedTabController = [self.tabBarController.viewControllers objectAtIndex:0];
	}
	else {
		if (self.tabBarController.moreNavigationController)
			self.tabBarController.moreNavigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	}
	[self setTabOrderIfSaved];
	
	[self.tabBarController setSelectedViewController:savedTabController];
	
	[self.mainWindow addSubview:self.tabBarController.view];		
}

- (void)runOnInitialAppStart:(id)sender {	
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	[self restoreArchivableSavedTableSelection];
	[self setupFeatures];

	NSArray *subviews = self.mainWindow.subviews;
	for (UIView *aView in subviews) {
		if (aView.tag == 8888) {
			[aView removeFromSuperview];
			break;
		}
	}
			 
	// register our preference selection data to be archived
	NSDictionary *savedPrefsDict = [NSDictionary dictionaryWithObjectsAndKeys: 
									[self archivableSavedTableSelection],kRestoreSelectionKey,
									[NSNumber numberWithBool:NO], kAnalyticsAskedForOptInKey,
									[NSNumber numberWithBool:YES], kAnalyticsSettingsSwitch,
									[NSNumber numberWithBool:NO], kShowedSplashScreenKey,
									[NSDictionary dictionary], kSegmentControlPrefKey,
									[NSNumber numberWithBool:NO], kResetChartCacheKey,
									[NSNumber numberWithBool:NO], kResetSavedDatabaseKey,
									version, @"CFBundleVersion",
									nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedPrefsDict];
	
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"CFBundleVersion"];
	[[NSUserDefaults standardUserDefaults] synchronize];
		
#ifdef DEBUG
	[[LocalyticsSession sharedLocalyticsSession] startSession:@"c3641d53749cde2eaf32359-2b477ece-c58f-11df-ee10-00fcbf263dff"];
#else
	[[LocalyticsSession sharedLocalyticsSession] startSession:@"8bde685867a8375008c3272-3afa437e-c58f-11df-ee10-00fcbf263dff"];
#endif
	
	[self runOnEveryAppStart];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
	[[TexLegeReachability sharedTexLegeReachability] startCheckingReachability];
	
	// initialize RestKit to handle our seed database and user database
	[TexLegeCoreDataUtils initRestKitObjects:self];	
	
    // Set up the mainWindow and content view
	UIWindow *localMainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainWindow = localMainWindow;
	[localMainWindow release];
		
	if (![UtilityMethods isIPadDevice]) {
		NSString *loadingString = @"Default.png";
		UIImage *loadingImage = [UIImage imageNamed:loadingString];
		UIImageView *loadingView = [[UIImageView alloc] initWithImage:loadingImage];
		loadingView.tag = 8888;
		[self.mainWindow addSubview:loadingView];
		[loadingView release];
		[self performSelector:@selector(runOnInitialAppStart:) withObject:nil afterDelay:0.0f];
	}
	else
		[self performSelector:@selector(runOnInitialAppStart:) withObject:nil];
	
	// make the window visible
	[self.mainWindow makeKeyAndVisible];
	
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	//[[UIApplication sharedApplication] setupScreenMirroring];
	[[TVOutManager sharedInstance] startTVOut];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//[[UIApplication sharedApplication] disableScreenMirroring];
	[[TVOutManager sharedInstance] stopTVOut];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[self runOnEveryAppStart];	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self runOnAppQuit];
}

- (void)applicationWillTerminate:(UIApplication *)application {	
	[self runOnAppQuit];
}

- (void)runOnEveryAppStart {
	self.appIsQuitting = NO;
	
	if (![self isDatabaseResetNeeded]) {
		analyticsOptInController = [[[AnalyticsOptInAlertController alloc] init] retain];
		if (analyticsOptInController && ![analyticsOptInController presentAnalyticsOptInAlertIfNecessary])
			[analyticsOptInController updateOptInFromSettings];
		
		if (self.dataUpdater)
			[self.dataUpdater performSelector:@selector(performDataUpdatesIfAvailable:) withObject:self afterDelay:10.f];
				
	}
	[[LocalyticsSession sharedLocalyticsSession] resume];
 	[[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)runOnAppQuit {
	if (self.appIsQuitting)
		return;
	self.appIsQuitting = YES;
	
	if (self.tabBarController) {
		// Smarten this up later for Core Data tab saving
		NSMutableArray *savedOrder = [NSMutableArray arrayWithCapacity:[self.tabBarController.viewControllers count]];
		NSArray *tabOrderToSave = self.tabBarController.viewControllers;
		
		for (UIViewController *aViewController in tabOrderToSave)
			[savedOrder addObject:aViewController.tabBarItem.title];
		
		[[NSUserDefaults standardUserDefaults] setObject:savedOrder forKey:kSavedTabOrderKey];
	}
	
	if (analyticsOptInController)
		[analyticsOptInController release], analyticsOptInController = nil;

	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:[self archivableSavedTableSelection] forKey:kRestoreSelectionKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];	
	
	[[LocalyticsSession sharedLocalyticsSession] close];
	[[LocalyticsSession sharedLocalyticsSession] upload];	
}

#pragma mark -
#pragma mark Saving

- (id) savedTableSelectionForKey:(NSString *)vcKey {
	id object = nil;
	@try {
		id savedVC = [self.savedTableSelection objectForKey:@"viewController"];
		if (vcKey && savedVC && [vcKey isEqualToString:savedVC])
			object = [self.savedTableSelection objectForKey:@"object"];
		
	}
	@catch (NSException * e) {
		[self resetSavedTableSelection:nil];
	}
	
	return object;
}

- (void)setSavedTableSelection:(id)object forKey:(NSString *)vcKey {
	if (!vcKey) {
		[self.savedTableSelection removeAllObjects];
		return;
	}
	[self.savedTableSelection setObject:vcKey forKey:@"viewController"];
	if (object)
		[self.savedTableSelection setObject:object forKey:@"object"];
	else
		[self.savedTableSelection removeObjectForKey:@"object"];
}

- (void)resetSavedTableSelection:(id)sender {
	self.savedTableSelection = [NSMutableDictionary dictionary];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kRestoreSelectionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreArchivableSavedTableSelection {
	@try {
		NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRestoreSelectionKey];
		if (data) {
			NSMutableDictionary *tempDict = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];	
			if (tempDict) {
				self.savedTableSelection = tempDict;
				[tempDict release];
			}	
		}		
	}
	@catch (NSException * e) {
		[self resetSavedTableSelection:nil];
	}

}

- (NSData *)archivableSavedTableSelection {
	NSData *data = nil;
	
	@try {
		NSMutableDictionary *tempDict = [self.savedTableSelection mutableCopy];
		data = [NSKeyedArchiver archivedDataWithRootObject:tempDict];
		[tempDict release];		
	}
	@catch (NSException * e) {
		[self resetSavedTableSelection:nil];
	}
	return data;
}

- (BOOL) isDatabaseResetNeeded {
	[[NSUserDefaults standardUserDefaults] synchronize];
	BOOL needsReset = [[NSUserDefaults standardUserDefaults] boolForKey:kResetSavedDatabaseKey];
		
	if (needsReset) {
		UIAlertView *resetDB = [[UIAlertView alloc] initWithTitle:[UtilityMethods texLegeStringWithKeyPath:@"ResetDB.ConfirmTitle"] 
														  message:[UtilityMethods texLegeStringWithKeyPath:@"ResetDB.ConfirmText"] 
														 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset",nil];
		resetDB.tag = 23452;
		[resetDB show];
		[resetDB release];
	}
	return needsReset;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 23452) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kResetSavedDatabaseKey];
		[[NSUserDefaults standardUserDefaults] synchronize];

		if (buttonIndex == alertView.firstOtherButtonIndex) {
			[self resetSavedTableSelection:nil];
			[TexLegeCoreDataUtils resetSavedDatabase:nil]; 
		}
	}
}

@end

