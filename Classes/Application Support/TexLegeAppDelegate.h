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
@class CommitteeMasterViewController;
@class GeneralTableViewController;
@class MenuPopoverViewController;
@class Appirater;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate, 
		AboutViewControllerDelegate, VoteInfoViewControllerDelegate, UIPopoverControllerDelegate> 
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
	NSMutableDictionary	*savedTableSelection;
	
	NSManagedObjectModel *managedObjectModel;
	IBOutlet NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	UIAlertView *hackingAlert;
	AboutViewController *aboutView;
	VoteInfoViewController *voteInfoView;
	UIViewController *activeDialogController;
	IBOutlet MenuPopoverViewController *menuPopoverVC;
	UIPopoverController *menuPopoverPC;
	
	NetworkStatus remoteHostStatus, internetConnectionStatus, localWiFiConnectionStatus;	

	UIWindow *mainWindow;
	Appirater *appirater;
	
	// For iPhone Interface
	IBOutlet UITabBarController *tabBarController;
	IBOutlet GeneralTableViewController *mapsTableTabbedVC, *linksTableTabbedVC, *calendarsTableTabbedVC;
	IBOutlet MasterTableViewController *legMasterTableViewController;
	IBOutlet CommitteeMasterViewController *committeeTableTabbedVC;
	
	// For iPad Interface
	IBOutlet UISplitViewController *splitViewController;
	IBOutlet UINavigationController *masterNavigationController, *detailNavigationController;
	IBOutlet id currentMasterViewController, currentDetailViewController;
	
	
@private
	NSMutableArray *functionalViewControllers;	
}
@property (nonatomic, retain) UIWindow			*mainWindow;
@property (nonatomic, retain) Appirater			*appirater;

@property (nonatomic, retain) NSMutableArray *functionalViewControllers;
@property (nonatomic, retain) MenuPopoverViewController *menuPopoverVC;
@property (nonatomic, retain) UIPopoverController *menuPopoverPC;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet GeneralTableViewController *mapsTableTabbedVC, *linksTableTabbedVC, *calendarsTableTabbedVC;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *masterNavigationController, *detailNavigationController;
@property (nonatomic, retain) IBOutlet id currentMasterViewController, currentDetailViewController;

@property (nonatomic, retain) IBOutlet CommitteeMasterViewController *committeeTableTabbedVC;
@property (nonatomic, retain) IBOutlet MasterTableViewController *legMasterTableViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSMutableArray		*savedLocation;
@property (nonatomic, retain) NSMutableDictionary	*savedTableSelection;
@property (nonatomic,readonly) NSString				*currentMasterViewControllerKey;

@property (nonatomic, retain) UIAlertView		*hackingAlert;
@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) VoteInfoViewController *voteInfoView;
@property (nonatomic, retain) UIViewController *activeDialogController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

//- (void)setTabOrderIfSaved;
- (IBAction)saveAction:sender;
- (IBAction)showOrHideMenuPopover:(id)sender;
- (IBAction)showOrHideAboutMenuPopover:(id)sender;

- (void)updateStatus;
- (NSInteger) indexForFunctionalViewController:(id)viewController;
- (NSInteger) indexForFunctionalViewControllerKey:(NSString *)vcKey;
- (void) changeActiveFeaturedControllerTo:(NSInteger)controllerIndex;

- (id) savedTableSelectionForKey:(NSString *)vcKey;
- (void)setSavedTableSelection:(id)object forKey:(NSString *)vcKey;

+ (TexLegeAppDelegate *)appDelegate;
@end
