//
//  TexLegeAppDelegate.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"

#import "LinksMenuDataSource.h"
#import "DirectoryDataSource.h"
#import "BillsDataSource.h"
#import "CommitteesDataSource.h"
#import "MapImagesDataSource.h"
#import "GeneralTableViewController.h"
#import "Reachability.h"
#import "Appirater.h"

@interface TexLegeAppDelegate(mymethods)
// these are private methods that outside classes need not use
- (void)setupDialogBoxes;
- (void)showHackingAlert;

- (NSString *)hostName;

@end

NSString *kRestoreLocationKey = @"RestoreLocation";	// preference key to obtain our restore location
NSUInteger kNumMaxTabs = 11;
NSInteger kNoSelection = -1;


@implementation TexLegeAppDelegate

//- (void) setupDialogBoxes;

@synthesize tabBarController, savedLocation;
@synthesize portraitWindow, hackingAlert;
@synthesize aboutView, voteInfoView, activeDialogController;
@synthesize remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;


- init {
	if (self = [super init]) {
		// initialize  to nil
		portraitWindow = nil;
		tabBarController = nil;
		activeDialogController = nil;
		hackingAlert = nil;
				
		[self setupDialogBoxes];
	}
	return self;
}


- (UINavigationController *)createNavigationControllerWrappingViewControllerForDataSourceOfClass:(Class)datasourceClass {
	// this is entirely a convenience method to reduce the repetition of the code
	// in the setupPortaitUserInterface
	// it returns a retained instance of the UINavigationController class. This is unusual, but 
	// it is necessary to limit the autorelease use as much as possible.
	
	id<TableDataSource,UITableViewDataSource> dataSource = [[datasourceClass alloc] init];

	// Core Data // is it necessary to do this here first?
	dataSource.managedObjectContext = self.managedObjectContext;
	
	// create the GeneralTableViewController and set the datasource
	GeneralTableViewController *theViewController;	
	theViewController = [[GeneralTableViewController alloc] initWithDataSource:dataSource];
	
	// create the navigation controller with the view controller
	UINavigationController *theNavigationController;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:theViewController];
	
	theNavigationController.navigationBar.barStyle = UIBarStyleBlack;	

	// before we return we can release the dataSource (it is now managed by the GeneralTableViewController instance
	[dataSource release];
		
	// and we can release the viewController because it is managed by the navigation controller
	[theViewController release];
	
	return theNavigationController;
}


- (void)setupPortraitUserInterface {
	UINavigationController *localNavigationController;
	
	tabBarController = [[UITabBarController alloc] init];	
	
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:kNumMaxTabs];
	
	// ********** setup the various view controllers for the different data representations
	
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[DirectoryDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	//localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[BillsDataSource class]];
	//[localViewControllersArray addObject:localNavigationController];
	//[localNavigationController release];
	
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[CommitteesDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[MapImagesDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
		
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[LinksMenuDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
		
	tabBarController.viewControllers = localViewControllersArray;
	[localViewControllersArray release];

	[portraitWindow addSubview:tabBarController.view];

}

// Not sure if this works ... we need more tabs to test.
- (void)setTabOrderIfSaved {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedOrder = [defaults arrayForKey:@"savedTabOrder"];
	NSMutableArray *orderedTabs = [NSMutableArray arrayWithCapacity:kNumMaxTabs];
	NSInteger i = 0;
	if ([savedOrder count] > 0 ) {
		for (i = 0; i < [savedOrder count]; i++){
			for (UIViewController *aController in tabBarController.viewControllers) {
				if ([aController.tabBarItem.title isEqualToString:[savedOrder objectAtIndex:i]]) {
					[orderedTabs addObject:aController];
				}
			}
		}
		tabBarController.viewControllers = orderedTabs;
	}
}

// Should we use this newer one instead?
// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
- (void)applicationDidFinishLaunching:(UIApplication *)application {		
	/*
     You can use the Reachability class to check the reachability of a remote host
     by specifying either the host's DNS name (www.apple.com) or by IP address.
     */
    [[Reachability sharedReachability] setHostName:[self hostName]];
	//[[Reachability sharedReachability] setAddress:@"0.0.0.0"];
    
    // The Reachability class is capable of notifying your application when the network
    // status changes. By default, those notifications are not enabled.
    // Uncomment the following line to enable them:
    //[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
        
    [self updateStatus];
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
    // Set up the portraitWindow and content view
	UIWindow *localPortraitWindow;
	localPortraitWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.portraitWindow = localPortraitWindow;
	// the localPortraitWindow data is now retained by the application delegate so we can release the local variable
	[localPortraitWindow release];
	
    [portraitWindow setBackgroundColor:[UIColor blackColor]];
	
	if (![UtilityMethods isThisCrantacular]) {
		// This app be hacked!
		
		[self showHackingAlert];
	}
	
	// load the stored preference of the user's last location from a previous launch
	NSMutableArray *tempMutableCopy = [[[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey] mutableCopy];
	self.savedLocation = tempMutableCopy;
	[tempMutableCopy release];
	if (savedLocation == nil)
	{
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
		savedLocation = [[NSMutableArray arrayWithObjects:
						  [NSNumber numberWithInteger:kNoSelection],	// tab selection at 1st level (-1 = no selection)
						  [NSNumber numberWithInteger:kNoSelection],	// .. row selection for underlying table
						  [NSNumber numberWithInteger:kNoSelection],	// .. section selection for underlying table
						  nil] retain];
	}
			
	// configure the portrait user interface
	[self setupPortraitUserInterface];
	
	[self setTabOrderIfSaved];
	
	NSInteger selection = [[savedLocation objectAtIndex:0] integerValue];	// read the saved selection at level 1
	if ((selection != kNoSelection) && (selection != tabBarController.selectedIndex)) {
		tabBarController.selectedIndex = selection;
	}
	
	// make the window visible
	[portraitWindow makeKeyAndVisible];
	
	// register our preference selection data to be archived
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:savedLocation forKey:kRestoreLocationKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[Appirater appLaunched];
		
}

- (void)applicationWillTerminate:(UIApplication *)application {

	/* maybe someday figure out how to update the Default.png 
	UIGraphicsBeginImageContext(self.portraitWindow.bounds.size);
	[self.portraitWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
	 
	 // some undocumented (CANT USE) methods in UIApplication:
	 -(void) _writeApplicationSnapshot;
	 -(void) _updateDefaultImage;
	 -(void) createApplicationDefaultPNG;
*/	
	
	NSInteger tabSelection = tabBarController.selectedIndex;
	NSInteger tabSavedSelection = [[savedLocation objectAtIndex:0] integerValue];

	if (tabSelection != tabSavedSelection) { // we're out of sync with the selection, clear the unknown
		[savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:tabSelection]];
		[savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:kNoSelection]];
		[savedLocation replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:kNoSelection]];
	}
	
	// Smarten this up later for Core Data tab saving
	NSMutableArray *savedOrder = [NSMutableArray arrayWithCapacity:kNumMaxTabs];
	NSArray *tabOrderToSave = tabBarController.viewControllers;
	
	for (UIViewController *aViewController in tabOrderToSave) {
		[savedOrder addObject:aViewController.tabBarItem.title];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:savedOrder forKey:@"savedTabOrder"];

	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:savedLocation forKey:kRestoreLocationKey];

	// Core Data Saving
	NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//exit(-1);  // Fail
        } 
    }
	
}


#pragma mark -
#pragma mark Alerts and Dialog Boxes

- (void)showHackingAlert {
	hackingAlert = [ [ UIAlertView alloc ] 
					initWithTitle:@"Suspected Hacking" 
					message:@"It appears this application may have been stolen.  If so, please purchase it at iTunes.  If this message is in error, please contact me. (at TexLege.com)" 
					delegate:self
					cancelButtonTitle: nil 
					otherButtonTitles: @"Go to TexLege.com", @"Buy in AppStore", nil];
	
	hackingAlert.delegate = self;
	[ hackingAlert show ];		
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	NSURL *goURL = nil;
	
	if (alertView == hackingAlert) {
		switch (buttonIndex) {
			case 1:
				goURL = [NSURL URLWithString:m_iTunesURL];
				break;
			case 0:
			default:
				goURL = [NSURL URLWithString:@"http://www.texlege.com/"];
				break;
		}
		if (![UtilityMethods openURLWithTrepidation:goURL]) 
				exit(0); // just quit if we can't open this url
	}
	[ alertView release ];
} 


- (void)setupDialogBoxes {    
	
	aboutView = [[[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil] retain];	
	aboutView.delegate = self;
	aboutView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	aboutView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	voteInfoView = [[[VoteInfoViewController alloc] initWithNibName:@"VoteInfoView" bundle:nil] retain];	
	voteInfoView.delegate = self;
	voteInfoView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	voteInfoView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
}

- (void)showAboutDialog:(UIViewController *)controller {
	activeDialogController = controller;
	if ((controller != nil) && (aboutView != nil))
		[controller presentModalViewController:aboutView animated:YES];
}

- (void)showVoteInfoDialog:(UIViewController *)controller {
	activeDialogController = controller;
	if ((controller != nil) && (voteInfoView != nil))
		[controller presentModalViewController:voteInfoView animated:YES];
}

- (void)VoteInfoViewControllerDidFinish:(VoteInfoViewController *)controller {
	if (activeDialogController != nil)
		[activeDialogController dismissModalViewControllerAnimated:YES];
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)controller {
	if (activeDialogController != nil)
		[activeDialogController dismissModalViewControllerAnimated:YES];
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
 
 if (self.remoteHostStatus == NotReachable) {
	cell.text = @"Cannot Connect To Remote Host.";
 } else if (self.remoteHostStatus == ReachableViaCarrierDataNetwork) {
	cell.text = @"Reachable Via Carrier Data Network.";
 } else if (self.remoteHostStatus == ReachableViaWiFiNetwork) {
	cell.text = @"Reachable Via WiFi Network.";
 }
 
 if (self.internetConnectionStatus == NotReachable) {
	cell.text = @"Access Not Available.";
 } else if (self.internetConnectionStatus == ReachableViaCarrierDataNetwork) {
	cell.text = @"Available Via Carrier Data Network.";
 } else if (self.internetConnectionStatus == ReachableViaWiFiNetwork) {
	cell.text = @"Available Via WiFi Network.";
 }
 
 if (self.localWiFiConnectionStatus == NotReachable) {
	cell.text = @"Access Not Available.";
 } else if (self.localWiFiConnectionStatus == ReachableViaWiFiNetwork) {
	cell.text = @"Available Via WiFi Network.";
 }
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
{
    // Don't include a scheme. 'http://' will break the reachability checking.
    // Change this value to test the reachability of a different host.
    return @"www.apple.com";
}

- (NSString *)hostNameLabel
{
    return [NSString stringWithFormat:@"Remote Host: %@", [self hostName]];
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//exit(-1);  // Fail
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
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: @"TexLege.sqlite"];

#if NEEDS_TO_INITIALIZE_DATABASE == 0 // don't use this if we're setting up & initializing from property lists...
	/*
	 Set up the store.
	 Provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"TexLege" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
#endif
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];

	NSError *error;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], 
							 NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], 
							 NSInferMappingModelAutomaticallyOption, nil];
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
		NSLog(@"error: %@", [error localizedFailureReason]);
    }    
		
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[tabBarController release];
	[portraitWindow release];    
	[savedLocation release];
	
	//[leakyControllerStack release];
	
	[aboutView release];
	[voteInfoView release];
	
    [super dealloc];
}

@end

