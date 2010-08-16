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
#import "Appirater.h"

#import "MiniBrowserController.h"
#import "CommonPopoversController.h"
#import "GeneralTableViewController.h"
#import "TableDataSourceProtocol.h"
#import "UIApplication+ScreenMirroring.h"

@interface TexLegeAppDelegate (Private)

// these are private methods that outside classes need not use
@property (nonatomic, retain) NSMutableArray *functionalViewControllers;

- (void)setupDialogBoxes;

- (void)setupFeatures;

- (NSString *)hostName;

- (void)restoreArchivableSavedTableSelection;
- (NSData *)archivableSavedTableSelection;
	
@end

// preference key to obtain our restore location
NSString *kRestoreSelectionKey = @"RestoreSelection";

NSUInteger kNumMaxTabs = 11;
NSInteger kNoSelection = -1;


@implementation TexLegeAppDelegate

//- (void) setupDialogBoxes;

@synthesize tabBarController;

@synthesize savedTableSelection;
@synthesize functionalViewControllers;

@synthesize mainWindow, appirater;
@synthesize aboutView, activeDialogController;
@synthesize remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;

@synthesize managedObjectContext;

@synthesize legislatorMasterVC, committeeMasterVC, capitolMapsMasterVC, linksMasterVC, calendarMasterVC;

@synthesize currentMasterViewController, currentDetailViewController;

+ (TexLegeAppDelegate *)appDelegate {
	return (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- init {
	if (self = [super init]) {
		// initialize  to nil
		mainWindow = nil;
		activeDialogController = nil;
		
		self.savedTableSelection = [NSMutableDictionary dictionaryWithCapacity:2];
		
		self.functionalViewControllers = [NSMutableArray array];
		
		[self setupDialogBoxes];
	}
	return self;
}

- (void)dealloc {

	self.currentDetailViewController = self.currentMasterViewController = nil;
	self.functionalViewControllers = nil;
	self.savedTableSelection = nil;

	self.activeDialogController = nil;
	self.aboutView = nil;
	self.tabBarController = nil;
	self.appirater = nil;
	self.mainWindow = nil;    
	
	self.capitolMapsMasterVC = nil;
	self.linksMasterVC = nil; 
	self.calendarMasterVC = nil;
	self.legislatorMasterVC = nil;
	self.committeeMasterVC = nil;

	self.managedObjectContext = nil;
		
	if (managedObjectModel)
		[managedObjectModel release], managedObjectModel = nil;
	if (persistentStoreCoordinator)
		[persistentStoreCoordinator release], persistentStoreCoordinator = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Data Sources and Main View Controllers


- (NSInteger) indexForFunctionalViewController:(id)viewController {
	NSInteger index = 0;
	if (self.functionalViewControllers && viewController) {
		index = [self.functionalViewControllers indexOfObject:viewController];
		if (index == NSNotFound)
			index = 0;
	}
	return index;
	
	#if 0
	if (!viewController)
		return 0;
	
	NSInteger index = 0;
	
	for (id splitVC in self.tabBarController.viewControllers) {
		UINavigationController *masterNav = [[splitVC viewControllers] objectAtIndex:0];
		if (masterNav && [[masterNav viewControllers] count]) {
			UIViewController *vc = [[masterNav viewControllers] objectAtIndex:0];
			if (vc && [vc isEqual:viewController])
				return index;
		}
		index++;
	}
	return 0;

	#endif
}

- (NSInteger) indexForFunctionalViewControllerKey:(NSString *)vcKey {
	if (self.functionalViewControllers && vcKey) {
		NSInteger tempIndex = 0;
		for (id vc in self.functionalViewControllers) {
			if ([vc isKindOfClass:[UIViewController class]] && [vc respondsToSelector:@selector(viewControllerKey)]) {
				NSString *tempVCKey = [vc performSelector:@selector(viewControllerKey)];
				if (tempVCKey && [tempVCKey isEqualToString:vcKey])
					return tempIndex;
			}
			tempIndex ++;
		}
	}
	return 0;
	
	#if 0
	if (!vcKey)
		return 0;
	
	NSInteger index = 0;
	
	for (id splitVC in self.tabBarController.viewControllers) {
		UINavigationController *masterNav = [[splitVC viewControllers] objectAtIndex:0];
		if (masterNav && [[masterNav viewControllers] count]) {
			UIViewController *vc = [[masterNav viewControllers] objectAtIndex:0];
			if (vc && [vc respondsToSelector:@selector(viewControllerKey)]) {
				NSString *tempVCKey = [vc performSelector:@selector(viewControllerKey)];
				if (tempVCKey && [tempVCKey isEqualToString:vcKey])
					return index;
			}
		}
		index++;
	}
	return 0;	

	
	#endif
}

////// IPAD ONLY
- (UISplitViewController *) splitViewController {
	if ([UtilityMethods isIPadDevice]) {
		return (UISplitViewController *)self.tabBarController.selectedViewController;
	}
	return nil;
}


////// IPAD ONLY
- (UINavigationController *) detailNavigationController {
	if ([UtilityMethods isIPadDevice]) {
		UISplitViewController *split = (UISplitViewController *)self.tabBarController.selectedViewController;
		if (split && [[split viewControllers] count])
			return [[split viewControllers] objectAtIndex:1];
	}
	return nil;
}

////// IPAD ONLY
- (UINavigationController *) masterNavigationController {
	if ([UtilityMethods isIPadDevice]) {
		UISplitViewController *split = (UISplitViewController *)self.tabBarController.selectedViewController;
		if (split && [[split viewControllers] count])
			return [[split viewControllers] objectAtIndex:0];
	}
	return nil;
}

///// IPAD ONLY
- (UIViewController *) currentDetailViewController {	
	if ([UtilityMethods isIPadDevice]) {
		return [[[self detailNavigationController] viewControllers] objectAtIndex:0];
	}
	else
		return currentDetailViewController;
}

////// IPAD ONLY
- (UIViewController *) currentMasterViewController {
	if ([UtilityMethods isIPadDevice]) {
		return [[[self masterNavigationController] viewControllers] objectAtIndex:0];
	}
	else
		return currentMasterViewController;
}


- (UIViewController *)topViewController {
	UIViewController *vc = nil;
	if ([UtilityMethods isIPadDevice]) {
		return [[self detailNavigationController] topViewController];
	}
	else {
		if ([self.tabBarController.selectedViewController respondsToSelector:@selector(topViewController)]) {
			vc = [self.tabBarController.selectedViewController performSelector:@selector(topViewController)];
		}
	}

	return vc;
}

- (void) changeActiveFeaturedControllerTo:(NSInteger)controllerIndex {	
	if (![UtilityMethods isIPadDevice]) {
		if (self.currentMasterViewController &&					// they're trying to select what they've already got
			[self indexForFunctionalViewController:self.currentMasterViewController] == controllerIndex)
			return;
	
		self.currentDetailViewController = nil;
		self.currentMasterViewController = [self.functionalViewControllers objectAtIndex:controllerIndex];
	}
	
	self.tabBarController.selectedIndex = controllerIndex;
	[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:nil];	


}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	// Dismiss the popover if it's present.
	//if (self.menuPopoverPC != nil) {
	//	[self.menuPopoverPC dismissPopoverAnimated:YES];
	//}
	[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:nil];	
}

- (void) setupFeatures {
	[[PartisanIndexStats sharedPartisanIndexStats] setManagedObjectContext:self.managedObjectContext];
	
	if ([UtilityMethods isIPadDevice] ) 
			[[NSBundle mainBundle] loadNibNamed:@"iPadTabBarController" owner:self options:nil];
//			[[NSBundle mainBundle] loadNibNamed:@"SplitViewController" owner:self options:NULL];
	else
			[[NSBundle mainBundle] loadNibNamed:@"iPhoneTabBarController" owner:self options:nil];
	
	
	[self.functionalViewControllers addObject:self.legislatorMasterVC];		// 0
	[self.functionalViewControllers addObject:self.committeeMasterVC];				// 1
	[self.functionalViewControllers addObject:self.calendarMasterVC];				// 2
	[self.functionalViewControllers addObject:self.capitolMapsMasterVC];					// 3
	[self.functionalViewControllers addObject:self.linksMasterVC];					// 4
	
	[self.legislatorMasterVC configureWithManagedObjectContext:self.managedObjectContext]; 
	[self.committeeMasterVC configureWithManagedObjectContext:self.managedObjectContext];
	[self.calendarMasterVC configureWithManagedObjectContext:self.managedObjectContext];
	[self.capitolMapsMasterVC configureWithManagedObjectContext:self.managedObjectContext];
	[self.linksMasterVC configureWithManagedObjectContext:self.managedObjectContext];
		
	NSMutableArray *splitViewControllers = [NSMutableArray arrayWithCapacity:[self.functionalViewControllers count]];
	if ([UtilityMethods isIPadDevice]) {
		NSInteger index = 0;
		for (GeneralTableViewController * controller in self.functionalViewControllers) {
			UISplitViewController * split = [controller splitViewController];
			if (split) {
				split.title = [[controller dataSource] name];
				split.tabBarItem = [[UITabBarItem alloc] initWithTitle:
									[[controller dataSource] name] image:[[controller dataSource] tabBarImage] tag:index];
				[splitViewControllers addObject:split];
			}
			index++;
		}
		[self.tabBarController setViewControllers:splitViewControllers];
	}
	
	[self.mainWindow addSubview:self.tabBarController.view];
	
	NSInteger selection = -1;
	NSString * tempVCKey = [self.savedTableSelection objectForKey:@"viewController"];
	if (tempVCKey) { // we have a saved view controller
		selection = [self indexForFunctionalViewControllerKey:tempVCKey];
	}
	if (selection < 0 || selection >= kNumMaxTabs) 
		selection = 0;
	[self changeActiveFeaturedControllerTo:selection];				
	
}


 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
		
    [[Reachability sharedReachability] setHostName:[self hostName]];
    
    // The Reachability class is capable of notifying your application when the network
    // status changes. By default, those notifications are not enabled.
    [[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
        
    [self updateStatus];
	
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
	
	// register our preference selection data to be archived
	NSDictionary *savedPrefsDict = [NSDictionary dictionaryWithObjectsAndKeys: 
									[self archivableSavedTableSelection],kRestoreSelectionKey,nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedPrefsDict];

	[[NSUserDefaults standardUserDefaults] synchronize];

	// [Appirater appLaunched];  This is replaced with the following, to avoid leakiness
	self.appirater = [[Appirater alloc] init];
	[NSThread detachNewThreadSelector:@selector(_appLaunched) toTarget:self.appirater withObject:nil];
		
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[UIApplication sharedApplication] setupScreenMirroring];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:[self archivableSavedTableSelection] forKey:kRestoreSelectionKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[UIApplication sharedApplication] disableScreenMirroring];
	
	// Core Data Saving
	[self saveAction:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {

	/* maybe someday figure out how to update the Default.png 
	UIGraphicsBeginImageContext(self.mainWindow.bounds.size);
	[self.mainWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
	 
	 // some undocumented (CANT USE) methods in UIApplication:
	 -(void) _writeApplicationSnapshot;
	 -(void) _updateDefaultImage;
	 -(void) createApplicationDefaultPNG;
*/	
/*
	NSInteger masterIndexSelection = 0;
	if (self.splitViewController) {
		masterIndexSelection = [self indexForFunctionalViewController:self.masterNavigationController];
	}
	else 
		if (self.tabBarController)
	{
		//if (self.tabBarController.selectedViewController != self.tabBarController.moreNavigationController)
		//	masterIndexSelection = self.tabBarController.selectedIndex;  // they had selected "More...", lets not go back there implicitly.

		masterIndexSelection = [self indexForFunctionalViewController:self.tabBarController.selectedViewController];
	}

*/	
	
	if (self.tabBarController) {
		// Smarten this up later for Core Data tab saving
		NSMutableArray *savedOrder = [NSMutableArray arrayWithCapacity:kNumMaxTabs];
		NSArray *tabOrderToSave = tabBarController.viewControllers;
		
		for (UIViewController *aViewController in tabOrderToSave) {
			[savedOrder addObject:aViewController.tabBarItem.title];
		}
		[[NSUserDefaults standardUserDefaults] setObject:savedOrder forKey:@"savedTabOrder"];
	}

	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:[self archivableSavedTableSelection] forKey:kRestoreSelectionKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];

	// Core Data Saving
	[self saveAction:nil];
}


#pragma mark -
#pragma mark Alerts and Dialog Boxes


- (void)setupDialogBoxes {    
	if (![UtilityMethods isIPadDevice]) {
		self.aboutView.delegate = self;
		self.aboutView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		self.aboutView.modalPresentationStyle = UIModalPresentationFormSheet;
	}
}

- (void)showAboutDialog:(UIViewController *)controller {
	if (![UtilityMethods isIPadDevice]) {
		self.activeDialogController = controller;
		if ((controller != nil) && (self.aboutView != nil))
			[controller presentModalViewController:self.aboutView animated:YES];
	}
}

- (void)modalViewControllerDidFinish:(UIViewController *)controller {
	if (![UtilityMethods isIPadDevice] && self.activeDialogController)
		[self.activeDialogController dismissModalViewControllerAnimated:YES];
}

/*
 
 // add this to init: or something
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
 (void)deviceOrientationDidChange:(void*)object { UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
 
 if (UIInterfaceOrientationIsLandscape(orientation)) {
 // do something
 } else {
 // do something else
 }
 }
 // add this to done: or something
 [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
 
 */


/*
 - (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
	// a cheat, so that we can dismiss all our popovers, if they're open.
}*/

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

- (NSString *)currentMasterViewControllerKey {
	if ([self.currentMasterViewController respondsToSelector:@selector(viewControllerKey)])
		return [self.currentMasterViewController performSelector:@selector(viewControllerKey)];
	return @"";
}

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
			// Handle error.
			debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}


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


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
	static NSString *DATABASE_NAME = @"TexLege.v2";
	static NSString *DATABASE_FILE = @"TexLege.v2.sqlite";
	
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: DATABASE_FILE];

#if NEEDS_TO_INITIALIZE_DATABASE == 0 // don't use this if we're setting up & initializing from property lists...
	/*
	 Set up the store.
	 Provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:DATABASE_NAME ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	debug_NSLog(@"%@", storePath);
#endif
	
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

