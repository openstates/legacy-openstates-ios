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

#import "LinksMenuDataSource.h"
#import "DirectoryDataSource.h"
#import "BillsDataSource.h"
#import "CommitteesDataSource.h"
#import "CapitolMapsDataSource.h"
#import "GeneralTableViewController.h"
#import "Reachability.h"
#import "Appirater.h"
#import "CPTestApp_iPadViewController.h"
#import "MiniBrowserController.h"

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

- (void)setupFeatures;

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

+ (TexLegeAppDelegate *)appDelegate {
	return (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

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

	self.currentDetailViewController = self.currentMasterViewController = nil;
	self.masterNavigationController = self.detailNavigationController = nil;
	self.functionalViewControllers = nil;
	self.savedLocation = nil;

	self.hackingAlert = self.activeDialogController = nil;
	self.menuPopoverVC = self.menuPopoverPC = nil;
	self.aboutView = self.voteInfoView = nil;
	self.tabBarController = self.splitViewController = nil;
	self.legMasterTableViewController = nil;
	self.appirater = nil;
	self.mainWindow = nil;    
	
	self.directoryTableTabbedVC = self.committeeTableTabbedVC = self.mapsTableTabbedVC = self.linksTableTabbedVC = self.corePlotTabbedVC = nil;
	//self.billsTableTabbedVC = nil;

	self.managedObjectContext = nil;
		
	if (managedObjectModel)
		[managedObjectModel release], managedObjectModel = nil;
	if (persistentStoreCoordinator)
		[persistentStoreCoordinator release], persistentStoreCoordinator = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Data Sources and Main View Controllers

/*
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
*/

- (NSInteger) indexForFunctionalViewController:(id)viewController {
	NSInteger index = 0;
	if (self.functionalViewControllers && viewController) {
		index = [self.functionalViewControllers indexOfObject:viewController];
		if (index == NSNotFound)
			index = 0;
	}
	return index;
}

- (void) changeActiveFeaturedControllerTo:(NSInteger)controllerIndex {
	// set the first component of our state saving business
	
	// GREG .... I mean it, set it ... this is a TODO!!!!!!!!!!!!!!!!!!!!!!!!
	
	if (self.currentDetailViewController)
		self.currentDetailViewController = nil;
	
	self.currentMasterViewController = [self.functionalViewControllers objectAtIndex:controllerIndex];
	
	switch (controllerIndex) {
		case 0:
			self.currentDetailViewController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
			break;
		case 1:
			self.currentDetailViewController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
			break;
		case 2:
			self.currentDetailViewController = [[CPTestApp_iPadViewController alloc] initWithNibName:@"CPTestApp_iPadViewController" bundle:nil];
			break;
		case 3:
			self.currentDetailViewController = [[MapsDetailViewController alloc] initWithNibName:@"MapsDetailViewController" bundle:nil];
			break;
		case 4:
			self.currentDetailViewController = [[MiniBrowserController alloc] initWithNibName:@"MiniBrowserView" bundle:nil];
			break;			
		default:
			self.currentDetailViewController = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
			NSLog(@"Unknown controller index in changeActiveFeaturedControllerTo: %d", controllerIndex);
			break;
	}
	
	[self.currentMasterViewController setValue:self.currentDetailViewController forKey:@"detailViewController"];
	
	if ([UtilityMethods isIPadDevice] && self.splitViewController) {
		//self.splitViewController.delegate = self.currentDetailViewController;	
		
		// Set up the view controller for the master.
		NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.currentMasterViewController, nil];
		self.masterNavigationController.viewControllers = viewControllers;
		[viewControllers release], viewControllers = nil;
		
		// now do the detail ...
		if (self.currentDetailViewController) {
			viewControllers = [[NSArray alloc] initWithObjects:self.currentDetailViewController, nil];
			self.detailNavigationController.viewControllers = viewControllers;
			[viewControllers release], viewControllers = nil;
			
			self.splitViewController.delegate = self.currentDetailViewController;	

		}

	}		
	else // it's an iPhone with a tabBar
		self.tabBarController.selectedIndex = controllerIndex;

	// Dismiss the popover if it's present.
	if (self.menuPopoverPC != nil) {
		[self.menuPopoverPC dismissPopoverAnimated:YES];
	}
	
	//	// Configure the new view controller's popover button (after the view has been displayed and its toolbar/navigation bar has been created).
	//	if (rootPopoverButtonItem != nil) {
	//		[detailViewController showRootPopoverButtonItem:self.rootPopoverButtonItem];
	//	}
}

- (void) setupFeatures {
	[[PartisanIndexStats sharedPartisanIndexStats] setManagedObjectContext:self.managedObjectContext];
	
	BOOL isIpad = [UtilityMethods isIPadDevice];
	
	if (isIpad) {
		if (splitViewController == nil) 
			[[NSBundle mainBundle] loadNibNamed:@"SplitViewController" owner:self options:NULL];
		if (self.legMasterTableViewController == nil)
			[[NSBundle mainBundle] loadNibNamed:@"MasterTableViewController" owner:self options:NULL];
	}
	else
		if (self.tabBarController == nil)
			[[NSBundle mainBundle] loadNibNamed:@"iPhoneTabBarController" owner:self options:nil];
	
	
	if (isIpad) [self.functionalViewControllers addObject:self.legMasterTableViewController];	// 0
	else		[self.functionalViewControllers addObject:self.directoryTableTabbedVC];			// 0
	
	[self.functionalViewControllers addObject:self.committeeTableTabbedVC];				// 1
	[self.functionalViewControllers addObject:self.corePlotTabbedVC];					// 2
	[self.functionalViewControllers addObject:self.mapsTableTabbedVC];					// 3
	[self.functionalViewControllers addObject:self.linksTableTabbedVC];					// 4
	
	if (isIpad)	[self.legMasterTableViewController configureWithDataSourceClass:
						[DirectoryDataSource class] andManagedObjectContext:self.managedObjectContext]; 
	else		[self.directoryTableTabbedVC configureWithDataSourceClass:
						[DirectoryDataSource class] andManagedObjectContext:self.managedObjectContext];
	[self.committeeTableTabbedVC configureWithDataSourceClass:[CommitteesDataSource class] andManagedObjectContext:self.managedObjectContext];
	[self.corePlotTabbedVC configureWithDataSourceClass:[DirectoryDataSource class] andManagedObjectContext:self.managedObjectContext];
	[self.mapsTableTabbedVC configureWithDataSourceClass:[CapitolMapsDataSource class] andManagedObjectContext:self.managedObjectContext];
	[self.linksTableTabbedVC configureWithDataSourceClass:[LinksMenuDataSource class] andManagedObjectContext:self.managedObjectContext];
	
	if (self.splitViewController)
		[self.mainWindow addSubview:self.splitViewController.view];
	else { 
		[self.mainWindow addSubview:self.tabBarController.view];
		//[self setTabOrderIfSaved];
	}
	
	NSInteger selection = [[savedLocation objectAtIndex:0] integerValue];	// read the saved selection at level 1
	if (selection > 0 && selection < kNumMaxTabs)				// do we have a valid selection?
		[self changeActiveFeaturedControllerTo:selection];				
	else
		[self changeActiveFeaturedControllerTo:0];				// just default to the first one, if we get troublesome data
	
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
    [[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
        
    [self updateStatus];
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
    // Set up the mainWindow and content view
	UIWindow *localMainWindow;
	localMainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainWindow = localMainWindow;
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

	[self setupFeatures];
			
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
	if (activeDialogController != nil)
		[activeDialogController dismissModalViewControllerAnimated:YES];
	if (self.menuPopoverPC && self.menuPopoverPC.contentViewController == self.aboutView)
		[self showOrHideAboutMenuPopover:controller];
}


-(IBAction)touchCommonMenuControl:(id)sender {
	NSInteger selectedSegment = -1;
	UISegmentedControl *tempCtl = nil;
	if ([sender isKindOfClass:[UISegmentedControl class]]) {
		tempCtl = (UISegmentedControl *)sender;
		selectedSegment = tempCtl.selectedSegmentIndex;
	}
	
	UIViewController *viewController = nil;
	
	switch (selectedSegment) {
		case 0:
			viewController = self.menuPopoverVC;
			break;
		case 1:
			viewController = self.aboutView;
			break;
		default:
			break;
	}
	
	if (self.menuPopoverPC) {
        [self.menuPopoverPC dismissPopoverAnimated:YES];
        self.menuPopoverPC = nil;
    } else if (viewController) {
		self.menuPopoverPC = [[UIPopoverController alloc] initWithContentViewController:viewController];
		self.menuPopoverPC.popoverContentSize = viewController.view.frame.size;
		self.menuPopoverPC.delegate = self;
		if (tempCtl) { // it's a segmented controller
			CGRect ctlRect = tempCtl.frame;
			CGFloat ctlHalfWidth = tempCtl.frame.size.width / [tempCtl numberOfSegments];	// two for right now
			ctlRect.size.width = ctlHalfWidth;
			ctlRect.origin.x += (selectedSegment * ctlHalfWidth); // to center it over the selected segment
			UIView *detailView = [self.detailNavigationController valueForKey:@"view"];
			[self.menuPopoverPC presentPopoverFromRect:ctlRect inView:detailView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else
			[self.menuPopoverPC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
	
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
		if ([sender isKindOfClass:[UISegmentedControl class]]) {
			UISegmentedControl *tempCtl = (UISegmentedControl *)sender;
			CGRect ctlRect = tempCtl.frame;
			ctlRect.size.width = [tempCtl widthForSegmentAtIndex:[tempCtl selectedSegmentIndex]];
			ctlRect.origin.x = ctlRect.origin.x + (ctlRect.size.width / 2);
			UIView *detailView = [self.currentDetailViewController valueForKey:@"view"];
			[self.menuPopoverPC presentPopoverFromRect:ctlRect inView:detailView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else
			[self.menuPopoverPC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
		if ([sender isKindOfClass:[UISegmentedControl class]]) {
			UISegmentedControl *tempCtl = (UISegmentedControl *)sender;
			CGRect ctlRect = tempCtl.frame;
			ctlRect.size.width = [tempCtl widthForSegmentAtIndex:[tempCtl selectedSegmentIndex]];
			[self.menuPopoverPC presentPopoverFromRect:ctlRect inView:tempCtl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else
			[self.menuPopoverPC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
//END:code.popover.menu


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// the user (not us) has dismissed the popover, let's cleanup.
	self.menuPopoverPC = nil;
	//if (tempCtl)
	//	[tempCtl setSelectedSegmentIndex:-1];

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
{	return @"www.apple.com";	}

- (NSString *)hostNameLabel
{	return [NSString stringWithFormat:@"Remote Host: %@", [self hostName]];	}

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
#endif
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	// GREG
	NSLog(@"%@", storePath);
	

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

