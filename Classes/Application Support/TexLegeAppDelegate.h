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

@class LegislatorDetailViewController, MasterTableViewController;

@interface TexLegeAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate, 
		AboutViewControllerDelegate, VoteInfoViewControllerDelegate> 
{
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	UIWindow *mainWindow;
	UITabBarController *tabBarController;
	UIAlertView *hackingAlert;
	
	NSMutableArray		*savedLocation;	// an array of selections for each drill level
	// i.e.
	// [0, 1, 3] =	select the top level / main tab 0,
	//				in the tableView, select detail with row 1
	//				......... and select detail with section 3
	// i.e.
	// [1, -1, -1] =	select tab 1,
	//					don't select a detail view
	
	AboutViewController *aboutView;
	VoteInfoViewController *voteInfoView;
	UIViewController *activeDialogController;
	
	NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;	
	
	IBOutlet MasterTableViewController *rootViewController;
    IBOutlet LegislatorDetailViewController *detailViewController;
	IBOutlet UISplitViewController *splitViewController;
	
}
@property (nonatomic, retain) UIWindow			*mainWindow;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet MasterTableViewController *rootViewController;
@property (nonatomic, retain) IBOutlet LegislatorDetailViewController *detailViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UIAlertView		*hackingAlert;

@property (nonatomic, retain) NSMutableArray	*savedLocation;

@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) VoteInfoViewController *voteInfoView;
@property (nonatomic, retain) UIViewController *activeDialogController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

- (void)setTabOrderIfSaved;
- (IBAction)saveAction:sender;

- (void)showAboutDialog:(UIViewController *)controller;
- (void)showVoteInfoDialog:(UIViewController *)controller;
- (void)updateStatus;

@end
