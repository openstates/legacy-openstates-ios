//
//  BillsDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@class TableCellDataObject;

@interface BillsDetailViewController : UITableViewController <RKRequestDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate/*, UIWebViewDelegate*/> {
	IBOutlet NSDictionary *bill;
	IBOutlet UIView *headerView, *descriptionView, *statusView;
	IBOutlet UITextView *lab_description;
	IBOutlet UILabel *lab_title;
	IBOutlet UIButton *starButton;
	IBOutlet UILabel *stat_filed, *stat_thisPassComm, *stat_thisPassVote, *stat_thatPassComm, *stat_thatPassVote, *stat_governor, *stat_isLaw;
	id dataObject;
}
@property (nonatomic,assign) id dataObject;

@property (nonatomic,retain) IBOutlet UIView *headerView, *descriptionView, *statusView;
@property (nonatomic,retain) IBOutlet UITextView *lab_description;
@property (nonatomic,retain) IBOutlet UILabel *lab_title;
@property (nonatomic,retain) IBOutlet UIButton *starButton;
@property (nonatomic,retain) IBOutlet UILabel *stat_filed, *stat_thisPassComm, *stat_thisPassVote, *stat_thatPassComm, *stat_thatPassVote, *stat_governor, *stat_isLaw;


@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic,retain) IBOutlet NSDictionary *bill;

- (IBAction)resetTableData:(id)sender;

- (IBAction)starButtonToggle:(id)sender;

@end
