//
//  MasterTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorDetailViewController;

@interface MasterTableViewController : UITableViewController {
	IBOutlet UISegmentedControl *chamberControl;
	IBOutlet LegislatorDetailViewController *legDetailViewController;
	
	NSMutableArray *testContent;
}


- (IBAction) filterChamber:(id)sender;

@property (nonatomic, retain) IBOutlet LegislatorDetailViewController *legDetailViewController;
@property (nonatomic, retain) IBOutlet NSMutableArray *testContent;
@end
