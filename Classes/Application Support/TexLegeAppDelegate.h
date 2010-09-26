//
//  TexLegeAppDelegate.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Reachability.h"

@class LegislatorMasterViewController;
@class CommitteeMasterViewController;
@class LinksMasterViewController;
@class CapitolMapsMasterViewController;
@class CalendarMasterViewController;
@class DistrictMapMasterViewController;
@class AnalyticsOptInAlertController;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate> 
{
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic)		  BOOL				appIsQuitting;
@property (nonatomic, retain) UIWindow			*mainWindow;
@property (nonatomic, retain) NSMutableDictionary	*savedTableSelection;

// For Core Data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// For Alerts and Modal Dialogs
@property (nonatomic, retain) AnalyticsOptInAlertController *analyticsOptInController;

// For Functional View Controllers
@property (nonatomic, assign) IBOutlet LinksMasterViewController *linksMasterVC;
@property (nonatomic, assign) IBOutlet CapitolMapsMasterViewController *capitolMapsMasterVC;
@property (nonatomic, assign) IBOutlet CommitteeMasterViewController *committeeMasterVC;
@property (nonatomic, assign) IBOutlet LegislatorMasterViewController *legislatorMasterVC;
@property (nonatomic, assign) IBOutlet CalendarMasterViewController *calendarMasterVC;
@property (nonatomic, assign) IBOutlet DistrictMapMasterViewController *districtMapMasterVC;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// For iPad Interface
@property (nonatomic, readonly)  UISplitViewController *splitViewController;
@property (nonatomic, readonly)  UIViewController *currentMasterViewController;//, *currentDetailViewController;
@property (nonatomic, readonly) UINavigationController * masterNavigationController, *detailNavigationController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

//- (void)setTabOrderIfSaved;
#if IMPORTING_DATA == 1
- (IBAction)saveAction:sender;
#endif

- (void)updateStatus;

- (id) savedTableSelectionForKey:(NSString *)vcKey;
- (void)setSavedTableSelection:(id)object forKey:(NSString *)vcKey;

+ (TexLegeAppDelegate *)appDelegate;

@end
