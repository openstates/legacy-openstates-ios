//
//  MasterTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"
#import "GeneralTableViewController.h"

@class LegislatorDetailViewController;

@interface LegislatorMasterViewController : GeneralTableViewController <UISearchDisplayDelegate> {
}


@property (nonatomic, retain) IBOutlet	UISegmentedControl	*chamberControl;
- (IBAction) filterChamber:(id)sender;

@end
