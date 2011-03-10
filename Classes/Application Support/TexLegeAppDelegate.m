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
- (void)runOnAppStart;
- (void)runOnAppQuit;
- (void)setupFeatures;
- (void)restoreArchivableSavedTableSelection;
- (NSData *)archivableSavedTableSelection;
- (void)resetSavedTableSelection:(id)sender;
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
@synthesize analyticsOptInController;
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
	}
	return self;
}

- (void)dealloc {
	self.savedTableSelection = nil;
	self.analyticsOptInController = nil;
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
	self.analyticsOptInController = nil;
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
/*	
				if ([[controller viewControllerKey] isEqualToString:@"CommitteeMasterViewController"]) {
					NSError *error = nil;
					NSInteger count = [CommitteeObj count:&error];
					if (error || count == 0)
						split.tabBarItem.enabled = NO;
				}		
*/
				[splitViewControllers addObject:split];
			}
			index++;
		}
		[self.tabBarController setViewControllers:splitViewControllers];
		[splitViewControllers release];
	} /*else {
		for (GeneralTableViewController *controller in VCs) {
			if ([[controller viewControllerKey] isEqualToString:@"CommitteeMasterViewController"]) {
				NSError *error = nil;
				NSInteger count = [CommitteeObj count:&error];
				if (error || count == 0)
					controller.navigationController.tabBarItem.enabled = NO;
			}		
		}
	}*/
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

- (void)finalizeStartup:(id)sender {	
	
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
	
	self.analyticsOptInController = [[[AnalyticsOptInAlertController alloc] init] autorelease];
	if (self.analyticsOptInController && ![self.analyticsOptInController presentAnalyticsOptInAlertIfNecessary])
		[self.analyticsOptInController updateOptInFromSettings];
	
#ifdef DEBUG
	[[LocalyticsSession sharedLocalyticsSession] startSession:@"c3641d53749cde2eaf32359-2b477ece-c58f-11df-ee10-00fcbf263dff"];
#else
	[[LocalyticsSession sharedLocalyticsSession] startSession:@"8bde685867a8375008c3272-3afa437e-c58f-11df-ee10-00fcbf263dff"];
#endif
	
	[self runOnAppStart];
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
		[self performSelector:@selector(finalizeStartup:) withObject:nil afterDelay:0.0f];
	}
	else
		[self performSelector:@selector(finalizeStartup:) withObject:nil];
	
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
	[self runOnAppStart];	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self runOnAppQuit];
}

- (void)applicationWillTerminate:(UIApplication *)application {	
	[self runOnAppQuit];
}

- (void)runOnAppStart {
	self.appIsQuitting = NO;
	
#ifdef BUILTINNOTRESTKIT
	if (![self resetSavedDatabaseIfNecessary])
		[self replaceOldDatabaseIfNeeded];
	else {
#endif	
		if (self.dataUpdater)
			[self.dataUpdater performSelector:@selector(checkAndAlertAvailableUpdates:) withObject:self afterDelay:10.f];
		
		if (self.analyticsOptInController && ![self.analyticsOptInController shouldPresentAnalyticsOptInAlert])
			[self.analyticsOptInController updateOptInFromSettings];
		
#ifdef BUILTINNOTRESTKIT
	}
#endif
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


#ifdef BUILTINNOTRESTKIT

#pragma mark -
#pragma mark Core Data stack

- (void)persistentStoreCopyStarted:(NSNotification *)aNotification {
	self.databaseIsCopying = YES;
}

- (void)persistentStoreCopyStopped:(NSNotification *)aNotification {
	self.databaseIsCopying = NO;
}

#define DATABASE_NAME @"TexLege.v3"
#define DATABASE_FILE @"TexLege.v3.sqlite"

- (void)copyPersistentStore:(id)sender {
#if IMPORTING_DATA == 0 // don't use this if we're setting up & initializing from property lists...
	
	[self performSelectorOnMainThread:@selector(resetSavedTableSelection:) withObject:nil waitUntilDone:YES];

	/*
	 Set up the store.
	 Provide a pre-populated default store.
	 */
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *storePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: DATABASE_FILE];
	NSFileManager *fileManager = [NSFileManager defaultManager];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENTSTORE_COPY_STARTED" object:nil];
		
	NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:DATABASE_NAME ofType:@"sqlite"];
	if (defaultStorePath) {
		NSError *error = nil;
		[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:&error];
		if (error) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENTSTORE_COPY_FAILED" object:nil];
			NSLog(@"Error attempting to copy persistent store to docs folder: %@", error);
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENTSTORE_COPY_COMPLETED" object:nil];	
			NSLog(@"Successfully created a backup database in %@", storePath);
		}
	}
	[pool drain];
#endif
}

- (void)switchPersistentStores:(NSNotification *)aNotification {
	[self persistentStoreCopyStopped:aNotification];
#warning this crap is broken
	NSString *storePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: DATABASE_FILE];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath isDirectory:NO];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:storePath]) {
		
		NSString *mainStorePath = [[NSBundle mainBundle] pathForResource:DATABASE_NAME ofType:@"sqlite"];
		NSURL *mainStoreURL = [NSURL fileURLWithPath:mainStorePath isDirectory:NO];
		NSPersistentStore *mainStore = [self.persistentStoreCoordinator persistentStoreForURL:mainStoreURL];
		if (mainStore) {
			NSError *error = nil;
			
			[self.persistentStoreCoordinator lock];

			NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], 
									 NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], 
									 NSInferMappingModelAutomaticallyOption, nil];
						
			[self.persistentStoreCoordinator removePersistentStore:mainStore error:&error];
			if (error) {
				NSLog(@"DB Switch error removing main store: %@", [error localizedFailureReason]);
			}
			else {
				NSPersistentStore *userStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
																							 configuration:nil 
																									   URL:storeURL 
																								   options:options 
																									 error:&error];    
				
				if (!userStore || error) {
					NSLog(@"DB Switch error adding user store: %@", [error localizedFailureReason]);
					abort();
				}
				
				else
					NSLog(@"DB Switch completed, new store at: %@", storeURL);
				
			}
			
			
			
			[self.persistentStoreCoordinator unlock];
		}
		
	}	
	self.managedObjectContext = nil;
	[persistentStoreCoordinator release];
	persistentStoreCoordinator = nil;
	[managedObjectModel release];
	managedObjectModel = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENTSTORE_SWITCHED" object:nil];	
}

- (void)copyPersistentStoreIfNeeded:(id)sender {	
#if IMPORTING_DATA == 0 // don't use this if we're setting up & initializing from property lists...

	NSString *storePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: DATABASE_FILE];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		[self copyPersistentStore:sender];
	}
#endif
}

- (BOOL)replaceOldDatabaseIfNeeded {
	BOOL hasOld = NO;
	
	// Save any custom notes, if we haven't done this already.
	NSDictionary *storedNotesDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"LEGE_NOTES"];	
	if (!storedNotesDict) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
		
		NSArray *legs = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"LegislatorObj" context:self.managedObjectContext];
		for (LegislatorObj *leg in legs) {
			if (leg.notes && [leg.notes length])
				[newDictionary setObject:leg.notes forKey:[leg.legislatorID stringValue]];
		}
		[[NSUserDefaults standardUserDefaults] setObject:newDictionary forKey:@"LEGE_NOTES"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[newDictionary release];
		[pool drain];
	}
	
	if (!databaseIsCopying) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		@try {
			DistrictMapObj *dist83 = [TexLegeCoreDataUtils districtMapForDistrict:[NSNumber numberWithInt:83] 
																	   andChamber:[NSNumber numberWithInt:HOUSE] 
																	  withContext:self.managedObjectContext 
																  lightProperties:YES];
			
			if (dist83) {
				NSNumber *coordinatesInPolygon = [dist83 valueForKey:@"numberOfCoords"];
				if (coordinatesInPolygon && [coordinatesInPolygon integerValue] == 315) {
					NSLog(@"TexLege has an older v3 database, resetting");
					[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"DATABASE_IS_OUTOFDATE"];
					hasOld = YES;
					
					UIAlertView *resetDB = [[UIAlertView alloc] initWithTitle:@"Replace Old Data File" 
																	  message:@"Your old TexLege user data file is outdated.  A reset is necessary to ensure application stability and data validity." 
																	 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset",nil];
					resetDB.tag = 5555;
					[resetDB show];
					[resetDB release];					
				}
				else
					NSLog(@"TexLege likely has a current v3 database");
			}
			
		}
		@catch (NSException * e) {
		}	
		
		[pool drain];
	}
	return hasOld;
}

- (void) resetSavedDatabase:(id)sender {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"DATABASE_RESET"];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSError *error = nil;
	NSString *pathToDocs = [UtilityMethods applicationDocumentsDirectory];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToDocs error:&error];
	
	if (error) {
		debug_NSLog(@"DB_RESET: Couldn't read documents directory for database reset: %@", error);
	}
	if (files && [files count]) {
		BOOL plannedFailure = NO;
		
		[self.persistentStoreCoordinator lock];	// no more changes
		for (NSPersistentStore *suspectStore in [self.persistentStoreCoordinator persistentStores]) {
			NSError *error = nil;
			[self.persistentStoreCoordinator removePersistentStore:suspectStore error:&error];
			if (error) {
				debug_NSLog(@"DB_RESET: Couldn't remove the database store... error: %@", [error localizedFailureReason]);
				plannedFailure = YES;
			}

		}

		for (NSString *file in files) {
			if ([file hasSuffix:@".sqlite"]) {
				NSString *filePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:file];
				NSError *error = nil;
				[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
				if (error) {
					debug_NSLog(@"DB_RESET: Couldn't remove the user's database file... error: %@", [error localizedFailureReason]);
					plannedFailure = YES;
				}
			}			
		}
		
		[self copyPersistentStoreIfNeeded:nil];		
		
		if (plannedFailure) {
			NSLog(@"DB_RESET: (FAIL, sort of) We had trouble in our attempts to reset the database, so we'll quit and see if the restart fixes it.");
		}
		else {
			NSLog(@"DB_RESET: (SUCCESS) Database removed and recreated.  The application must now quit.  Restart it at your convenience.");
		}
		exit(0);

/*		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], 
								 NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], 
								 NSInferMappingModelAutomaticallyOption, nil];
		
		NSString *inDocsPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:DATABASE_FILE];
		NSURL *storeUrl = [NSURL fileURLWithPath:inDocsPath];
		
		if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
			// Handle the error.
			debug_NSLog(@"error: %@", [error localizedFailureReason]);
			NSLog(@"We had trouble in our attempts to add the new database, so we'll quit and see if the restart fixes it.");
			exit(0);
		} 
		[self.persistentStoreCoordinator unlock];
*/
	}	
	[pool drain];
}

- (BOOL) resetSavedDatabaseIfNecessary {
	
	BOOL needsReset = [[NSUserDefaults standardUserDefaults] boolForKey:kResetSavedDatabaseKey];
	
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kResetSavedDatabaseKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (needsReset) {
		UIAlertView *resetDB = [[UIAlertView alloc] initWithTitle:@"Settings: Reset Data and Quit?" 
														  message:@"Are you sure you want to restore the factory database?  Any interim data updates will be lost by proceeding.  NOTE: The application will automatically quit after the reset." 
														 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset",nil];
		resetDB.tag = 5555;
		[resetDB show];
		[resetDB release];
	}
	
	return needsReset;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		[self resetSavedTableSelection:nil];
		if (alertView.tag == 5555)
			[self resetSavedDatabase:nil]; 
	}
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
#define IF_WE_ALLOW_SAVING_IN_CORE_DATA_USE_A_COPY_OF_THE_DB 1


#if IMPORTING_DATA == 1
	#define IF_WE_ALLOW_SAVING_IN_CORE_DATA_USE_A_COPY_OF_THE_DB 1
#endif
	
	NSString *storePath = nil;
	NSString *inMainBundle = [[NSBundle mainBundle] pathForResource:DATABASE_NAME ofType:@"sqlite"];
	
	BOOL createNewStore = NO;
#if IMPORTING_DATA == 1
	
	if (!inMainBundle) {
		createNewStore = YES;
		
		NSString *appBundlePath = [[NSBundle mainBundle] bundlePath];
		storePath = [appBundlePath stringByAppendingPathComponent:DATABASE_FILE];
	}
#endif
		
	if (!createNewStore) {
#ifdef IF_WE_ALLOW_SAVING_IN_CORE_DATA_USE_A_COPY_OF_THE_DB
		NSString *inDocsPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:DATABASE_FILE];
		if (![[NSFileManager defaultManager] fileExistsAtPath:inDocsPath]) {
			storePath = inMainBundle;  // for now at least until it gets copies properly
			[self performSelectorInBackground:@selector(copyPersistentStore:) withObject:nil];
			
			// Need to find a way to tell the core data objects that we've got a new/safer persistent store ready to go
		}
		else {
			storePath = inDocsPath;
		}
		
#else
		storePath = inMainBundle;
#endif
	}
	debug_NSLog(@"%@", storePath);
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];

	NSError *error;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], 
							 NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], 
							 NSInferMappingModelAutomaticallyOption, nil];
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
		debug_NSLog(@"error: %@", [error localizedFailureReason]);
    }    
		
    return persistentStoreCoordinator;
}

#endif

@end

