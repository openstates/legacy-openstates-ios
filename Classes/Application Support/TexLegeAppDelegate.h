//
//  TexLegeAppDelegate.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "AboutViewController.h"
#import "Reachability.h"

@class MasterTableViewController;
@class CommitteeMasterViewController;
@class GeneralTableViewController;
@class MenuPopoverViewController;
@class Appirater;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate, 
		AboutViewControllerDelegate, UIPopoverControllerDelegate> 
{
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain) UIWindow			*mainWindow;
@property (nonatomic, retain) Appirater			*appirater;

// For Persistent View Selection
// savedLocation: an array of selections for each drill level
// i.e.
// [0, 1, 3] =	select the top level / main tab 0,
//				in the tableView, select detail with row 1
//				......... and select detail with section 3
// i.e.
// [1, -1, -1] =	select tab 1,
//					don't select a detail view
@property (nonatomic, retain) NSMutableArray		*savedLocation;
@property (nonatomic, retain) NSMutableDictionary	*savedTableSelection;
@property (nonatomic,readonly) NSString				*currentMasterViewControllerKey;

// For Core Data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// For Alerts and Modal Dialogs
@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) UIViewController *activeDialogController;
@property (nonatomic, retain) UIPopoverController *menuPopoverPC;

// For Functional View Controllers
@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, retain) NSMutableArray *functionalViewControllers;
@property (nonatomic, retain) IBOutlet GeneralTableViewController *mapsTableTabbedVC, *linksTableTabbedVC, *calendarsTableTabbedVC;
@property (nonatomic, retain) IBOutlet CommitteeMasterViewController *committeeTableTabbedVC;
@property (nonatomic, retain) IBOutlet MasterTableViewController *legMasterTableViewController;

// For iPhone Interface
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// For iPad Interface
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *masterNavigationController, *detailNavigationController;
@property (nonatomic, retain) IBOutlet id currentMasterViewController, currentDetailViewController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

//- (void)setTabOrderIfSaved;
- (IBAction)saveAction:sender;
- (IBAction)showOrHideAboutMenuPopover:(id)sender;

- (void)updateStatus;
- (NSInteger) indexForFunctionalViewController:(id)viewController;
- (NSInteger) indexForFunctionalViewControllerKey:(NSString *)vcKey;
- (void) changeActiveFeaturedControllerTo:(NSInteger)controllerIndex;


- (id) savedTableSelectionForKey:(NSString *)vcKey;
- (void)setSavedTableSelection:(id)object forKey:(NSString *)vcKey;

+ (TexLegeAppDelegate *)appDelegate;
@end
