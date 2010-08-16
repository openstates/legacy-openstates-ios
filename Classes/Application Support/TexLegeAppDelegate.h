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

@class LegislatorMasterViewController;
@class CommitteeMasterViewController;
@class LinksMasterViewController;
@class CapitolMapsMasterViewController;
@class CalendarMasterViewController;
@class Appirater;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate, 
		AboutViewControllerDelegate> 
{
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain) UIWindow			*mainWindow;
@property (nonatomic, retain) Appirater			*appirater;

@property (nonatomic, retain) NSMutableDictionary	*savedTableSelection;
@property (nonatomic,readonly) NSString				*currentMasterViewControllerKey;

// For Core Data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// For Alerts and Modal Dialogs
@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) UIViewController *activeDialogController;

// For Functional View Controllers
@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, retain) NSMutableArray *functionalViewControllers;
@property (nonatomic, retain) IBOutlet LinksMasterViewController *linksMasterVC;
@property (nonatomic, retain) IBOutlet CapitolMapsMasterViewController *capitolMapsMasterVC;
@property (nonatomic, retain) IBOutlet CommitteeMasterViewController *committeeMasterVC;
@property (nonatomic, retain) IBOutlet LegislatorMasterViewController *legislatorMasterVC;
@property (nonatomic, retain) IBOutlet CalendarMasterViewController *calendarMasterVC;

// For iPhone Interface
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// For iPad Interface
@property (nonatomic, readonly)  UISplitViewController *splitViewController;
@property (nonatomic, retain)  id currentMasterViewController, currentDetailViewController;
@property (nonatomic, readonly) UINavigationController * detailNavigationController;
@property (nonatomic, readonly) UINavigationController * masterNavigationController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

//- (void)setTabOrderIfSaved;
- (IBAction)saveAction:sender;

- (void)updateStatus;
- (NSInteger) indexForFunctionalViewController:(id)viewController;
- (NSInteger) indexForFunctionalViewControllerKey:(NSString *)vcKey;
- (void) changeActiveFeaturedControllerTo:(NSInteger)controllerIndex;


- (id) savedTableSelectionForKey:(NSString *)vcKey;
- (void)setSavedTableSelection:(id)object forKey:(NSString *)vcKey;

+ (TexLegeAppDelegate *)appDelegate;
@end
