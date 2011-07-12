//
//  StatesLegeAppDelegate.h
//  Created by Gregory Combs on 7/22/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@class LegislatorMasterViewController;
@class CommitteeMasterViewController;
@class LinksMasterViewController;
@class CalendarMasterViewController;
@class DistrictMapMasterViewController;
@class BillsMasterViewController;
@class DataModelUpdateManager;
@class AnalyticsOptInAlertController;

@interface StatesLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate, UINavigationControllerDelegate> 
{
	DataModelUpdateManager *dataUpdater;
	UIWindow			*mainWindow;
	NSMutableDictionary	*savedTableSelection;
	BOOL				appIsQuitting;
	AnalyticsOptInAlertController *analyticsOptInController;
	IBOutlet LinksMasterViewController *linksMasterVC;
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

// For Functional View Controllers
@property (nonatomic, assign) IBOutlet LinksMasterViewController *linksMasterVC;
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
- (void)changingReachability:(id)sender;

+ (StatesLegeAppDelegate *)appDelegate;

@end
