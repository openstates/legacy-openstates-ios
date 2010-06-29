//
//  LegislatorDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;

@interface LegislatorDetailViewController : UITableViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
    UIPopoverController *popoverController;

	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *legInfoTable;
	
	IBOutlet UISlider *indivSlider, *partySlider, *allSlider;
	IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
	IBOutlet UIView *indivView, *partyView, *allView;
	
	NSString *tempLegislator;
	LegislatorObj *legislator;
}

@property (nonatomic, retain) NSString *tempLegislator;
@property (nonatomic, retain) LegislatorObj *legislator;

@end
