//
//  CommitteeDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommitteeObj;
@class PartisanScaleView;
@interface CommitteeDetailViewController : UITableViewController <UISplitViewControllerDelegate> 

@property (nonatomic, retain) CommitteeObj *committee;
@property (nonatomic, retain) UIPopoverController *masterPopover;
@property (nonatomic, retain) IBOutlet UILabel *membershipLab;
@property (nonatomic, retain) IBOutlet PartisanScaleView *partisanSlider;
@property (nonatomic, retain) NSMutableArray *infoSectionArray;
@end
