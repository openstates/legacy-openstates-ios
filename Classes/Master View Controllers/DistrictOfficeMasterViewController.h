//
//  DistrictOfficeMasterViewController.h
//  TexLege
//
//  Created by Gregory Combs on 8/23/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"
#import "GeneralTableViewController.h"

@class MapViewController;
@interface DistrictOfficeMasterViewController : GeneralTableViewController <UISearchDisplayDelegate>  {

}
@property (nonatomic, retain) IBOutlet	UISegmentedControl	*chamberControl;
@property (nonatomic, retain) IBOutlet	UISegmentedControl	*sortControl;
@property (nonatomic, retain) IBOutlet	UIView	*filterControls;
- (IBAction) filterChamber:(id)sender;
- (IBAction) sortType:(id)sender;

@end
