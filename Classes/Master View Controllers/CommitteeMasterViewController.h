//
//  CommitteeMasterViewController.h
//
//  Created by Gregory Combs on 8/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"
#import "GeneralTableViewController.h"

@class CommitteeDetailViewController;

@interface CommitteeMasterViewController : GeneralTableViewController <UISearchDisplayDelegate> {
	IBOutlet	UISegmentedControl	*chamberControl;
}

@property (nonatomic, retain) IBOutlet	UISegmentedControl	*chamberControl;

- (IBAction) filterChamber:(id)sender;
@end
