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
#import "CPTestApp_iPadViewController.h"
#import "MenuPopoverViewController.h"


#import "LegislatorDetailViewController.h"
#import "MapsDetailViewController.h"
#import "CommitteeDetailViewController.h"


@interface TexLegeAppDelegate (Private)

// these are private methods that outside classes need not use
@property (nonatomic, retain) NSMutableArray *functionalViewControllers;

- (void)setupDialogBoxes;
- (void)showHackingAlert;
- (void)iPhoneUserInterfaceInit;

- (NSString *)hostName;
- (NSInteger) addFunctionalViewController:(id)viewController;

@end

// preference key to obtain our restore location
NSString *kRestoreLocationKey = @"RestoreLocation";			// old, simplistic key/array used on original iphone-only app.
//NSString *kRestoreLocationKey = @"HybridRestoreLocation";

NSUInteger kNumMaxTabs = 11;
NSInteger kNoSelection = -1;


@implementation TexLegeAppDelegate

//- (void) setupDialogBoxes;

@synthesize tabBarController;
@synthesize savedLocation;
@synthesize functionalViewControllers;
@synthesize menuPopoverVC, menuPopoverPC;

@synthesize mainWindow, hackingAlert, appirater;
@synthesize aboutView, voteInfoView, activeDialogController;
@synthesize remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;

@synthesize managedObjectContext;

@synthesize directoryTableTabbedVC, committeeTableTabbedVC, mapsTableTabbedVC, linksTableTabbedVC, corePlotTabbedVC;
//@synthesize billsTableTabbedVC;

@synthesize masterNavigationController, detailNavigationController;
@synthesize currentMasterViewController, currentDetailViewController;
@synthesize splitViewController, legMasterTableViewController;

- init {
	if (self = [super init]) {
		// initialize  to nil
		mainWindow = nil;
		//tabBarController = nil;
		activeDialogController = nil;
		hackingAlert = nil;
		savedLocation = nil;

		self.functionalViewControllers = [NSMutableArray array];
		
		[self setupDialogBoxes];
	}
	return self;
}

- (void)dealloc {
	self.savedLocation = nil;
	self.functionalViewControllers = nil;
	self.menuPopoverVC = nil;
	self.menuPopoverPC = nil;
	self.aboutView = nil;
	self.voteInfoView = nil;
	self.tabBarController = nil;
	self.splitViewController = nil;
	self.legMasterTableViewController = nil;
	self.appirater = nil;
	[mainWindow release];    
	
	self.directoryTableTabbedVC = self.committeeTableTabbedVC = self.mapsTableTabbedVC = self.linksTableTabbedVC = self.corePlotTabbedVC = nil;
	//self.billsTableTabbedVC = nil;

	self.managedObjectContext = nil;
    [managedObjectModel release];
    [persistentStoreCoordinator release];
		
    [super dealloc];
}


#pragma mark -
#pragma mark Data Sources and Main View Controllers

// Not sure if this works ... we need more tabs to test.
- (void)setTabOrderIfSaved {
	if ([UtilityMethods isIPadDevice] == NO && self.tabBarController) {

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *savedOrder = [defaults arrayForKey:@"savedTabOrder"];		/// saves the order of the titles
		NSMutableArray *orderedControllers = [[NSMutableArray alloc] init];
		
		if ([savedOrder count] > 0 ) {
			
			for (id loopItem in savedOrder){
				for (UIViewController *aController in tabBarController.viewControllers) {
					if ([aController.tabBarItem.title isEqualToString:loopItem]) {
						[orderedControllers addObject:aController];
					}
				}
			}
			tabBarController.viewControllers = orderedControllers;
			self.functionalViewControllers = orderedControllers;  // replace our existing order
		}
		if (orderedControllers) [orderedControllers release], orderedControllers = nil;
	}
}

- (NSInteger) indexForFunctionalViewController:(id)viewController {
	NSInteger index = 0;
	if (self.functionalViewControllers && viewController) {
		index = [self.functionalViewControllers indexOfObject:viewController];
		if (index == NSNotFound)
			index = 0;
	}
	return index;
}

- (NSInteger) addFunctionalViewController:(id)viewController {
	NSInteger index = 0;
	
	if (viewController && self.functionalViewControllers) {
		NSInteger existingIndex = NSNotFound;
		if ((existingIndex = [self.functionalViewControllers indexOfObject:viewController]) != NSNotFound) 
			// we already have it in our array
			index = existingIndex;
		else {
			index = [self.functionalViewControllers count];
			[self.functionalViewControllers addObject:viewController];
		}
	}
	return index;
}

- (void) changeActiveFeaturedControllerTo:(NSString *)controllerString {
	if (controllerString) {
		// set the first component of our state saving business
		
		// GREG .... I mean it, set it ... this is a TODO!!!!!!!!!!!!!!!!!!!!!!!!
		
		if (self.currentDetailViewController)
			self.currentDetailViewController = nil;

		if ([controllerString isEqualToString:@"MasterTableViewController"]) {
			self.currentMasterViewController = self.legMasterTableViewController;
			self.currentDetailViewController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
			[self.currentMasterViewController setValue:self.currentDetailViewController forKey:@"detailViewController"];
			self.splitViewController.delegate = self.currentDetailViewController;
		}
		else if ([controllerString isEqualToString:@"CommitteeTableViewController"]) {
			self.currentMasterViewController = self.committeeTableTabbedVC;
			self.currentDetailViewController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
			[self.currentMasterViewController setValue:self.currentDetailViewController forKey:@"detailViewController"];
			self.splitViewController.delegate = self.currentDetailViewController;
		}
		else if ([controllerString isEqualToString:@"MapsTableViewController"]) {
			self.currentMasterViewController = self.mapsTableTabbedVC;
			self.currentDetailViewController = [[MapsDetailViewController alloc] initWithNibName:@"MapsDetailViewController" bundle:nil];
			[self.currentMasterViewController setValue:self.currentDetailViewController forKey:@"detailViewController"];
			self.splitViewController.delegate = self.currentDetailViewController;
		}
		
		
		// Set up the view controller for the master.
		NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.currentMasterViewController, nil];
		self.masterNavigationController.viewControllers = viewControllers;
		[viewControllers release], viewControllers = nil;
		
		// now do the detail ...
		if (self.currentDetailViewController) {
			viewControllers = [[NSArray alloc] initWithObjects:self.currentDetailViewController, nil];
			self.detailNavigationController.viewControllers = viewControllers;
			[viewControllers release], viewControllers = nil;

		}
		
		// Dismiss the popover if it's present.
		if (self.menuPopoverPC != nil) {
			[self.menuPopoverPC dismissPopoverAnimated:YES];
		}
		
		//	// Configure the new view controller's popover button (after the view has been displayed and its toolbar/navigation bar has been created).
		//	if (rootPopoverButtonItem != nil) {
		//		[detailViewController showRootPopoverButtonItem:self.rootPopoverButtonItem];
		//	}
		
	}
	
}

// ********** setup the various view controllers for the different data representations
- (void) constructDataSourcesAndInitMainViewControllers
{
	if ([UtilityMethods isIPadDevice]) { // we're on an iPad, use the splitViewController
		if (splitViewController == nil) 
			[[NSBundle mainBundle] loadNibNamed:@"SplitViewController" owner:self options:NULL];
		
		if (self.legMasterTableViewController == nil)
			[[NSBundle mainBundle] loadNibNamed:@"MasterTableViewController" owner:self options:NULL];
			
		[self changeActiveFeaturedControllerTo:@"MasterTableViewController"];
		//[self changeActiveFeaturedControllerTo:@"CommitteeTableViewController"];
		//[self changeActiveFeaturedControllerTo:@"MapsTableViewController"];
		
		[self addFunctionalViewController:self.legMasterTableViewController];
		//[self addFunctionalViewController:self.directoryTableTabbedVC];
		[self addFunctionalViewController:self.committeeTableTabbedVC];
		[self addFunctionalViewController:self.corePlotTabbedVC];
		[self addFunctionalViewController:self.mapsTableTabbedVC];
		[self addFunctionalViewController:self.linksTableTabbedVC];
		
		[self.legMasterTableViewController configureWithDataSourceClass:[DirectoryDataSource class] andManagedObjectContext:self.managedObjectContext]; 
		//[self.directoryTableTabbedVC configureWithDataSourceClass:[DirectoryDataSource class] andManagedObjectContext:self.managedObjectContext];
		[self.committeeTableTabbedVC configureWithDataSourceClass:[CommitteesDataSource class] andManagedObjectContext:self.managedObjectContext];
		[self.mapsTableTabbedVC configureWithDataSourceClass:[MapImagesDataSource class] andManagedObjectContext:self.managedObjectContext];
		[self.linksTableTabbedVC configureWithDataSourceClass:[LinksMenuDataSource class] andManagedObjectContext:self.managedObjectContext];

		[self.mainWindow addSubview:splitViewController.view];
		
		NSInteger selection = [[savedLocation objectAtIndex:0] integerValue];	// read the saved selection at level 1
		if (selection != kNoSelection && selection > 0) { // it's not the first one, so change things up...
			NSString * vcString = [[self.functionalViewControllers objectAtIndex:selection] name];
			if (vcString) {
				
				[self changeActiveFeaturedControllerTo:vcString];				
			}
		}				 
		
	}
	else {  // We're on an iPhone/iTouch using the tabBarController
		if (self.tabBarController == nil)
			//tabBarController = [[UITabBarController alloc] initWithNibName:@"iPhoneTabBarController" bundle:nil];
			[[NSBundle mainBundle] loadNibNamed:@"iPhoneTabBarController" owner:self options:nil];

		[self.directoryTableTabbedVC configureWithDataSourceClass:[DirectoryDataSource class] andManagedObjectContext:self.managedObjectContext];
		[self.committeeTableTabbedVC configureWithDataSourceClass:[CommitteesDataSource class] andManagedObjectContext:self.managedObjectContext];
		[self.mapsTableTabbedVC configureWithDataSourceClass:[MapImagesDataSource class] andManagedObjectContext:self.managedObjectContext];
		[self.linksTableTabbedVC configureWithDataSourceClass:[LinksMenuDataSource class] andManagedObjectContext:self.managedObjectContext];
		
		[self.mainWindow addSubview:tabBarController.view];
		
		[self setTabOrderIfSaved];

		NSInteger selection = [[savedLocation objectAtIndex:0] integerValue];	// read the saved selection at level 1
		if ((selection != kNoSelection) && (selection != tabBarController.selectedIndex)) {
			tabBarController.selectedIndex = selection;
		}
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
	
    // Set up the mainWindow and content view
	UIWindow *localMainWindow;
	localMainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainWindow = localMainWindow;
	// the localMainWindow data is now retained by the application delegate so we can release the local variable
	[localMainWindow release];
	
    [self.mainWindow setBackgroundColor:[UIColor whiteColor]];
	
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

	[self constructDataSourcesAndInitMainViewControllers];
			
	// make the window visible
	[self.mainWindow makeKeyAndVisible];
	
	// register our preference selection data to be archived
	NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:savedLocation forKey:kRestoreLocationKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	[[NSUserDefaults standardUserDefaults] synchronize];

	// [Appirater appLaunched];  This is replaced with the following, to avoid leakiness
	self.appirater = [[Appirater alloc] init];
	[NSThread detachNewThreadSelector:@selector(_appLaunched) toTarget:self.appirater withObject:nil];
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

	NSInteger masterIndexSelection = 0;
#if 0  /// this is a work in progress ... trouble is that the splitViewController has intermediate UINavigationControllers!!!
	if (self.splitViewController && [self.splitViewController.viewControllers count]) {
		UIViewController *splitMasterVC = [self.splitViewController.viewControllers objectAtIndex:0]; // this is the master (left)
		UIViewController *splitDetailVC = [self.splitViewController.viewControllers objectAtIndex:1]; // this is the detail (right)

		if (splitMasterVC) {
			masterIndexSelection = [self indexForFunctionalViewController:splitMasterVC];
		}
	}
	else 
#endif
	if (self.tabBarController)
	{
		//if (self.tabBarController.selectedViewController != self.tabBarController.moreNavigationController)
		//	masterIndexSelection = self.tabBarController.selectedIndex;  // they had selected "More...", lets not go back there implicitly.

		masterIndexSelection = [self indexForFunctionalViewController:self.tabBarController.selectedViewController];
	}


	NSInteger tabSavedSelection = [[savedLocation objectAtIndex:0] integerValue];

	if (masterIndexSelection != tabSavedSelection) { // we're out of sync with the selection, clear the unknown
		[savedLocation replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:masterIndexSelection]];
		[savedLocation replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:kNoSelection]];
		[savedLocation replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:kNoSelection]];
	}
	
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
	[[NSUserDefaults standardUserDefaults] setObject:savedLocation forKey:kRestoreLocationKey];
	
	[[NSUserDefaults standardUserDefaults] synchronize];

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
//	aboutView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	aboutView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	aboutView.modalPresentationStyle = UIModalPresentationFormSheet;
//	aboutView.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	voteInfoView = [[[VoteInfoViewController alloc] initWithNibName:@"VoteInfoView" bundle:nil] retain];	
	voteInfoView.delegate = self;
//	voteInfoView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	voteInfoView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	voteInfoView.modalPresentationStyle = UIModalPresentationFormSheet;
//	voteInfoView.modalPresentationStyle = UIModalPresentationCurrentContext;
	
}

- (void)showAboutDialog:(UIViewController *)controller {
	activeDialogController = controller;
	if ((controller != nil) && (self.aboutView != nil))
		[controller presentModalViewController:self.aboutView animated:YES];
}

- (void)showVoteInfoDialog:(UIViewController *)controller {
	activeDialogController = controller;
	if ((controller != nil) && (self.voteInfoView != nil))
		[controller presentModalViewController:self.voteInfoView animated:YES];
}

- (void)modalViewControllerDidFinish:(UIViewController *)controller {
	if (self.menuPopoverPC && self.menuPopoverPC.contentViewController == self.aboutView) {
		[self showOrHideAboutMenuPopover:controller];
	}
	else if (activeDialogController != nil)
		[activeDialogController dismissModalViewControllerAnimated:YES];
}

//END:code.gestures.color
//START:code.popover.menu
-(IBAction)showOrHideAboutMenuPopover:(id)sender {
    if (self.menuPopoverPC) {
        [self.menuPopoverPC dismissPopoverAnimated:YES];
        self.menuPopoverPC = nil;
    } else {
		self.menuPopoverPC = [[UIPopoverController alloc] initWithContentViewController:self.aboutView];
		self.menuPopoverPC.popoverContentSize = self.aboutView.view.frame.size;
		self.menuPopoverPC.delegate = self;
		[self.menuPopoverPC presentPopoverFromBarButtonItem:sender 
							  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
//END:code.popover.menu

//END:code.gestures.color
//START:code.popover.menu
-(IBAction)showOrHideMenuPopover:(id)sender {
    if (self.menuPopoverPC) {
        [self.menuPopoverPC dismissPopoverAnimated:YES];
        self.menuPopoverPC = nil;
    } else {
		self.menuPopoverPC = [[UIPopoverController alloc] initWithContentViewController:self.menuPopoverVC];
		self.menuPopoverPC.popoverContentSize = self.menuPopoverVC.view.frame.size;
		self.menuPopoverPC.delegate = self;
		[self.menuPopoverPC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
//END:code.popover.menu


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// the user (not us) has dismissed the popover, let's cleanup.
	self.menuPopoverPC = nil;
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


- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
	// a cheat, so that we can dismiss all our popovers, if they're open.
	
	if (self.menuPopoverPC) {
		// if we're actually showing the menu, and not the about box, close out any active menu dialogs too
		if (self.menuPopoverVC && self.menuPopoverVC == self.menuPopoverPC.contentViewController)
			[self.menuPopoverVC modalViewControllerDidFinish:nil];
		
        [self.menuPopoverPC dismissPopoverAnimated:YES];
        self.menuPopoverPC = nil;
	}
		
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


@end

