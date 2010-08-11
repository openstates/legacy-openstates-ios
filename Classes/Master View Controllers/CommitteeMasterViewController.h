//
//  CommitteeMasterViewController.h
//
//  Created by Gregory Combs on 8/3/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"

@class CommitteeDetailViewController;

@interface CommitteeMasterViewController : UITableViewController <UISearchDisplayDelegate> {
}

@property (nonatomic,retain)			id					selectObjectOnAppear;
@property (nonatomic, retain) IBOutlet	id<TableDataSource> dataSource;
@property (nonatomic, retain) IBOutlet CommitteeDetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet	UISegmentedControl	*chamberControl;
@property (nonatomic,readonly)			NSString			*viewControllerKey;

- (IBAction) filterChamber:(id)sender;
- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context;

@end
