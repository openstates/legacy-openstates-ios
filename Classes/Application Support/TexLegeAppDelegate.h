//
//  TexLegeAppDelegate.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "VoteInfoViewController.h"
#import "AboutViewController.h"
#import "Reachability.h"
#import "MenuPopoverViewController.h"

@class LegislatorDetailViewController, MasterTableViewController;
@class GeneralTableViewController;
@class CPTestApp_iPadViewController;
@class MenuPopoverViewController;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate, 
		AboutViewControllerDelegate, VoteInfoViewControllerDelegate> 
{
	// savedLocation: an array of selections for each drill level
	// i.e.
	// [0, 1, 3] =	select the top level / main tab 0,
	//				in the tableView, select detail with row 1
	//				......... and select detail with section 3
	// i.e.
	// [1, -1, -1] =	select tab 1,
	//					don't select a detail view
	NSMutableArray		*savedLocation;
	
	NSManagedObjectModel *managedObjectModel;
	IBOutlet NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	UIAlertView *hackingAlert;
	AboutViewController *aboutView;
	VoteInfoViewController *voteInfoView;
	UIViewController *activeDialogController;
	IBOutlet MenuPopoverViewController *menuPopoverVC;
	UIPopoverController *menuPopoverPC;
	
	NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;	

	UIWindow *mainWindow;
	
	// For iPhone Interface
	IBOutlet UITabBarController *tabBarController;
	IBOutlet GeneralTableViewController *directoryTableTabbedVC, *committeeTableTabbedVC, *mapsTableTabbedVC, *linksTableTabbedVC;
	//IBOutlet GeneralTableViewController *billsTableTabbedVC;
	
	// For iPad Interface
	IBOutlet UISplitViewController *splitViewController;
	IBOutlet MasterTableViewController *masterTableViewController;
    IBOutlet LegislatorDetailViewController *detailViewController;
		
	IBOutlet CPTestApp_iPadViewController *corePlotTabbedVC;
	
@private
	NSMutableArray *functionalViewControllers;	
}
@property (nonatomic, retain) UIWindow			*mainWindow;

@property (nonatomic, retain) NSMutableArray *functionalViewControllers;
@property (nonatomic, retain) MenuPopoverViewController *menuPopoverVC;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet GeneralTableViewController *directoryTableTabbedVC, *committeeTableTabbedVC, *mapsTableTabbedVC, *linksTableTabbedVC;
//@property (nonatomic, retain) IBOutlet GeneralTableViewController *billsTableTabbedVC;

@property (nonatomic, retain) IBOutlet CPTestApp_iPadViewController *corePlotTabbedVC;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet MasterTableViewController *masterTableViewController;
@property (nonatomic, retain) IBOutlet LegislatorDetailViewController *detailViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSMutableArray	*savedLocation;

@property (nonatomic, retain) UIAlertView		*hackingAlert;
@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) VoteInfoViewController *voteInfoView;
@property (nonatomic, retain) UIViewController *activeDialogController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

- (void)setTabOrderIfSaved;
- (IBAction)saveAction:sender;
- (IBAction)showOrHideMenuPopover:(id)sender;
- (IBAction)showOrHideAboutMenuPopover:(id)sender;

- (void)updateStatus;

@end
