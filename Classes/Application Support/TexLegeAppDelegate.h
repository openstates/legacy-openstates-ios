//
//  TexLegeAppDelegate.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

@class LegislatorMasterViewController;
@class CommitteeMasterViewController;
@class LinksMasterViewController;
@class CapitolMapsMasterViewController;
@class CalendarMasterViewController;
@class DistrictMapMasterViewController;
@class BillsMasterViewController;
@class AnalyticsOptInAlertController;
@class DataModelUpdateManager;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate> 
{
	DataModelUpdateManager *dataUpdater;
	UIWindow			*mainWindow;
	NSMutableDictionary	*savedTableSelection;
	BOOL				appIsQuitting;
	AnalyticsOptInAlertController *analyticsOptInController;
	IBOutlet LinksMasterViewController *linksMasterVC;
	IBOutlet CapitolMapsMasterViewController *capitolMapsMasterVC;
	IBOutlet CommitteeMasterViewController *committeeMasterVC;
	IBOutlet LegislatorMasterViewController *legislatorMasterVC;
	IBOutlet CalendarMasterViewController *calendarMasterVC;
	IBOutlet DistrictMapMasterViewController *districtMapMasterVC;
	IBOutlet BillsMasterViewController *billsMasterVC;
	IBOutlet UITabBarController *tabBarController;	
}
@property (nonatomic, retain) DataModelUpdateManager *dataUpdater;
@property (nonatomic, retain) UIWindow			*mainWindow;
@property (nonatomic, retain) NSMutableDictionary	*savedTableSelection;
@property (nonatomic)		  BOOL				appIsQuitting;


// For Alerts and Modal Dialogs
@property (nonatomic, retain) AnalyticsOptInAlertController *analyticsOptInController;

// For Functional View Controllers
@property (nonatomic, assign) IBOutlet LinksMasterViewController *linksMasterVC;
@property (nonatomic, assign) IBOutlet CapitolMapsMasterViewController *capitolMapsMasterVC;
@property (nonatomic, assign) IBOutlet CommitteeMasterViewController *committeeMasterVC;
@property (nonatomic, assign) IBOutlet LegislatorMasterViewController *legislatorMasterVC;
@property (nonatomic, assign) IBOutlet CalendarMasterViewController *calendarMasterVC;
@property (nonatomic, assign) IBOutlet DistrictMapMasterViewController *districtMapMasterVC;
@property (nonatomic, assign) IBOutlet BillsMasterViewController *billsMasterVC;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// For iPad Interface
@property (nonatomic, readonly)  UISplitViewController *splitViewController;
@property (nonatomic, readonly)  UIViewController *currentMasterViewController;//, *currentDetailViewController;
@property (nonatomic, readonly)  UINavigationController * masterNavigationController, *detailNavigationController;

//- (void)setTabOrderIfSaved;

- (id) savedTableSelectionForKey:(NSString *)vcKey;
- (void)setSavedTableSelection:(id)object forKey:(NSString *)vcKey;

+ (TexLegeAppDelegate *)appDelegate;

@end
