//
//  MasterTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"

@class LegislatorDetailViewController;

@interface MasterTableViewController : UITableViewController <UISearchDisplayDelegate> {
	IBOutlet UISegmentedControl *chamberControl;
	IBOutlet LegislatorDetailViewController *detailViewController;
	IBOutlet id<TableDataSource> dataSource;
	IBOutlet UISearchBar *searchBar;
	
	IBOutlet UIBarButtonItem *menuButton;
	id selectObjectOnAppear;
	UISearchDisplayController *m_searchDisplayController;
}


- (IBAction) filterChamber:(id)sender;
@property (nonatomic,retain) id selectObjectOnAppear;
@property (nonatomic, retain) IBOutlet id<TableDataSource> dataSource;
@property (nonatomic, retain) IBOutlet LegislatorDetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *chamberControl;
@property (nonatomic, retain) UISearchDisplayController *m_searchDisplayController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *menuButton;

@property (nonatomic,readonly) NSString *viewControllerKey;

- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context;

@end
