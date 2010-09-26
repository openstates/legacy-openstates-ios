//
//  TexLegeAppDelegate.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"
#import "PartisanIndexStats.h"

#import "Reachability.h"

#import "MiniBrowserController.h"
#import "GeneralTableViewController.h"
#import "TableDataSourceProtocol.h"
#import "UIApplication+ScreenMirroring.h"
#import "AnalyticsOptInAlertController.h"

#import "LocalyticsSession.h"
#import "DistrictMapDataSource.h"

//#import "JSONDataImporter.h"

#if IMPORTING_DATA == 1
#import "TexLegeDataImporter.h"
#endif

#if EXPORTING_DATA == 1
#import "TexLegeDataExporter.h"
#endif

@interface TexLegeAppDelegate (Private)

- (void)setupFeatures;

- (NSString *)hostName;

- (void)restoreArchivableSavedTableSelection;
- (NSData *)archivableSavedTableSelection;
	
@end

// user default dictionary keys
NSString * const kRestoreSelectionKey = @"RestoreSelection";
NSString * const kAnalyticsAskedForOptInKey = @"HasAskedForOptIn";
NSString * const kAnalyticsSettingsSwitch = @"PermitUseOfAnalytics";
NSString * const kShowedSplashScreenKey = @"HasShownSplashScreen";
NSString * const kSegmentControlPrefKey = @"SegmentControlPrefs";
NSString * const kResetChartCacheKey = @"ResetChartCache";

NSUInteger kNumMaxTabs = 11;
NSInteger kNoSelection = -1;


@implementation TexLegeAppDelegate

@synthesize tabBarController;
@synthesize savedTableSelection, appIsQuitting;

@synthesize mainWindow;
@synthesize analyticsOptInController;
@synthesize remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;

@synthesize managedObjectContext;

@synthesize legislatorMasterVC, committeeMasterVC, capitolMapsMasterVC, linksMasterVC, calendarMasterVC, districtMapMasterVC;

+ (TexLegeAppDelegate *)appDelegate {
	return (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- init {
	if (self = [super init]) {
		// initialize  to nil
		mainWindow = nil;
		self.appIsQuitting = NO;
		self.savedTableSelection = [NSMutableDictionary dictionaryWithCapacity:2];
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

	self.managedObjectContext = nil;
		
	if (managedObjectModel)
		[managedObjectModel release], managedObjectModel = nil;
	if (persistentStoreCoordinator)
		[persistentStoreCoordinator release], persistentStoreCoordinator = nil;
	
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
	NSArray *savedOrder = [defaults arrayForKey:@"savedTabOrder"];
	NSMutableArray *orderedTabs = [NSMutableArray arrayWithCapacity:[self.tabBarController.viewControllers count]];
	if ([savedOrder count] > 0 ) {
		for (NSInteger i = 0; i < [savedOrder count]; i++){
			for (UIViewController *aController in self.tabBarController.viewControllers) {
				if ([aController.tabBarItem.title isEqualToString:[savedOrder objectAtIndex:i]]) {
					[orderedTabs addObject:aController];
				}
			}
		}
		tabBarController.viewControllers = orderedTabs;
	}
}

- (void) setupFeatures {
	
	[[PartisanIndexStats sharedPartisanIndexStats] setManagedObjectContext:self.managedObjectContext];
	
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
					self.calendarMasterVC, self.capitolMapsMasterVC, self.linksMasterVC, nil];
	
	NSString * tempVCKey = [self.savedTableSelection objectForKey:@"viewController"];
	NSInteger savedTabSelectionIndex = -1;
	NSInteger loopIndex = 0;
	for (GeneralTableViewController *masterVC in VCs) {
		[masterVC configureWithManagedObjectContext:self.managedObjectContext];
		
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
	[VCs release];
	
	id savedTabController = [self.tabBarController.viewControllers objectAtIndex:savedTabSelectionIndex];
	if (!savedTabController) {
		debug_NSLog (@"Couldn't find a view/navigation controller at index: %d", savedTabSelectionIndex);
		savedTabController = [self.tabBarController.viewControllers objectAtIndex:0];
	}
	
	[self setTabOrderIfSaved];
	
	[self.tabBarController setSelectedViewController:savedTabController];
	
	[self.mainWindow addSubview:self.tabBarController.view];
		
	//self.districtMapDataSource = [[[DistrictMapDataSource alloc] initWithManagedObjectContext:self.managedObjectContext] autorelease];
	//[self.tabBarController setSelectedIndex:selection];
}


 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
		
#if IMPORTING_DATA == 1
	TexLegeDataImporter *importer = [[TexLegeDataImporter alloc] initWithManagedObjectContext:self.managedObjectContext];
	[importer importAllDataObjects];
	//[importer importObjectsWithEntityName:@"LinkObj"];

	[importer release];
#endif
	
	[[Reachability sharedReachability] setHostName:[self hostName]];
	[self updateStatus];
	[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
	[self updateStatus];	// we do this twice because of an issue with concurrence, one must be synchronous
		
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
    // Set up the mainWindow and content view
	UIWindow *localMainWindow;
	localMainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainWindow = localMainWindow;
	[localMainWindow release];
	
    [self.mainWindow setBackgroundColor:[UIColor whiteColor]];
	
	[self restoreArchivableSavedTableSelection];
	[self setupFeatures];
			
	// make the window visible
	[self.mainWindow makeKeyAndVisible];

	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

	
	// register our preference selection data to be archived
	NSDictionary *savedPrefsDict = [NSDictionary dictionaryWithObjectsAndKeys: 
									[self archivableSavedTableSelection],kRestoreSelectionKey,
									[NSNumber numberWithBool:NO], kAnalyticsAskedForOptInKey,
									[NSNumber numberWithBool:YES], kAnalyticsSettingsSwitch,
									[NSNumber numberWithBool:NO], kShowedSplashScreenKey,
									[NSDictionary dictionary], kSegmentControlPrefKey,
									[NSNumber numberWithBool:NO], kResetChartCacheKey,
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
	
#if EXPORTING_DATA == 1
	TexLegeDataExporter *exporter = [[TexLegeDataExporter alloc] initWithManagedObjectContext:self.managedObjectContext];
	[exporter exportAllDataObjects];
	[exporter release];
#endif
	
	//JSONDataImporter *jsonImporter = [[JSONDataImporter alloc] initWithManagedObjectContext:self.managedObjectContext];
	//[jsonImporter release];
	
	
	return YES;
}



- (void)prepareToQuit {
	if (self.appIsQuitting)
		return;
	self.appIsQuitting = YES;
	
	if (self.tabBarController) {
		// Smarten this up later for Core Data tab saving
		NSMutableArray *savedOrder = [NSMutableArray arrayWithCapacity:[self.tabBarController.viewControllers count]];
		NSArray *tabOrderToSave = self.tabBarController.viewControllers;
		
		for (UIViewController *aViewController in tabOrderToSave) {
			[savedOrder addObject:aViewController.tabBarItem.title];
		}
		[[NSUserDefaults standardUserDefaults] setObject:savedOrder forKey:@"savedTabOrder"];
	}
	
	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:[self archivableSavedTableSelection] forKey:kRestoreSelectionKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Core Data Saving
#if IMPORTING_DATA == 1
	[self saveAction:nil];	
#endif
}



- (void)applicationDidBecomeActive:(UIApplication *)application		{[[UIApplication sharedApplication] setupScreenMirroring];}

- (void)applicationWillResignActive:(UIApplication *)application	{[[UIApplication sharedApplication] disableScreenMirroring];}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	self.appIsQuitting = NO;
	
	if (self.analyticsOptInController && ![self.analyticsOptInController shouldPresentAnalyticsOptInAlert])
		[self.analyticsOptInController updateOptInFromSettings];
	
 	[[LocalyticsSession sharedLocalyticsSession] resume];
 	[[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self prepareToQuit];
	[[LocalyticsSession sharedLocalyticsSession] close];
	[[LocalyticsSession sharedLocalyticsSession] upload];	
}

- (void)applicationWillTerminate:(UIApplication *)application {	
	[self prepareToQuit];
	[[LocalyticsSession sharedLocalyticsSession] close];
	[[LocalyticsSession sharedLocalyticsSession] upload];	
}


#pragma mark - 
#pragma mark Reachability

/*
 Remote Host Reachable
 Not reachable | Reachable via EDGE | Reachable via WiFi
 
 Connection to Internet
 Not available | Available via EDGE | Available via WiFi
 
 Connection to Local Network.
 Not available | Available via WiFi
*/

- (void)reachabilityChanged:(NSNotification *)note
{
    [self updateStatus];
}

- (void)updateStatus
{
    // Query the SystemConfiguration framework for the state of the device's network connections.
    self.remoteHostStatus           = [[Reachability sharedReachability] remoteHostStatus];
    self.internetConnectionStatus    = [[Reachability sharedReachability] internetConnectionStatus];
    self.localWiFiConnectionStatus    = [[Reachability sharedReachability] localWiFiConnectionStatus];
}


- (BOOL)isCarrierDataNetworkActive
{
    return (self.remoteHostStatus == ReachableViaCarrierDataNetwork);
}

- (NSString *)hostName
{	return @"www.apple.com";	}

- (NSString *)hostNameLabel
{	return [NSString stringWithFormat:@"Remote Host: %@", [self hostName]];	}

#pragma mark -
#pragma mark Saving

- (id) savedTableSelectionForKey:(NSString *)vcKey {
	id object = nil;
	id savedVC = [self.savedTableSelection objectForKey:@"viewController"];
	if (vcKey && savedVC && [vcKey isEqualToString:savedVC])
		object = [self.savedTableSelection objectForKey:@"object"];
	
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

- (void)restoreArchivableSavedTableSelection {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kRestoreSelectionKey];
	if (data) {
		NSMutableDictionary *tempDict = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];	
		if (tempDict) {
			id object = [tempDict objectForKey:@"object"];
			if (object && [object isKindOfClass:[NSURL class]] && [[object scheme] isEqualToString:@"x-coredata"])	{		// try to get a managed object ID				
				NSManagedObjectID *tempID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:object];
				if (tempID)
					[tempDict setObject:tempID forKey:@"object"]; 
			}
			
			self.savedTableSelection = tempDict;
			[tempDict release];
		}	
	}
}

- (NSData *)archivableSavedTableSelection {
	NSMutableDictionary *tempDict = [self.savedTableSelection mutableCopy];
	id object = [tempDict objectForKey:@"object"];
	if (object && [object isKindOfClass:[NSManagedObjectID class]])
		[tempDict setObject:[object URIRepresentation] forKey:@"object"]; 

	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tempDict];
	[tempDict release];
	return data;
}

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
#if IMPORTING_DATA == 1

- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
			// Handle error.
			debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}
#endif


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	NSString *path = [[NSBundle mainBundle] pathForResource:@"TexLege" ofType:@"momd"];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];

    //managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


#define DATABASE_NAME @"TexLege.v2"
#define DATABASE_FILE @"TexLege.v2.sqlite"

- (void)copyPersistentStoreIfNeeded:(id)sender {	
#if IMPORTING_DATA == 0 // don't use this if we're setting up & initializing from property lists...
	/*
	 Set up the store.
	 Provide a pre-populated default store.
	 */
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *storePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: DATABASE_FILE];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:DATABASE_NAME ofType:@"sqlite"];
		if (defaultStorePath) {
			NSError *error = nil;
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:&error];
			if (error)
				NSLog(@"Error attempting to copy persistent store to docs folder: %@", error);
			else {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"PERSISTENT_STORE_COPIED" object:storePath];	
				NSLog(@"Successfully created a backup database in %@", storePath);
			}
		}
	}
	[pool drain];
#endif
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
#ifdef IF_WE_ALLOW_SAVING_IN_CORE_DATA_USE_A_COPY_OF_THE_DB
	NSString *inDocsPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:DATABASE_FILE];

	if (![[NSFileManager defaultManager] fileExistsAtPath:inDocsPath]) {
		storePath = inMainBundle;  // for now at least until it gets copies properly
		[self performSelectorInBackground:@selector(copyPersistentStoreIfNeeded:) withObject:nil];
		
		// Need to find a way to tell the core data objects that we've got a new/safer persistent store ready to go
	}
	else {
		storePath = inDocsPath;
	}

#else
	storePath = inMainBundle;
#endif
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


@end

