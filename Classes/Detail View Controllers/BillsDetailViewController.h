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
@class DDActionHeaderView;
@class BillVotesDataSource;
@class AppendingFlowView;
@interface BillsDetailViewController : UITableViewController <RKRequestDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate> {
	IBOutlet NSMutableDictionary *bill;
	IBOutlet UIView *headerView, *descriptionView;
	IBOutlet AppendingFlowView *statusView;
	IBOutlet UITextView *lab_description;
	IBOutlet UIButton *starButton;
	IBOutlet DDActionHeaderView *actionHeader;
	id dataObject;
	BillVotesDataSource *voteDS;
}
@property (nonatomic,assign) id dataObject;

@property (nonatomic,retain) IBOutlet UIView *headerView, *descriptionView;
@property (nonatomic,retain) IBOutlet AppendingFlowView *statusView;
@property (nonatomic,retain) IBOutlet UITextView *lab_description;
@property (nonatomic,retain) IBOutlet UIButton *starButton;
@property (nonatomic,retain) IBOutlet DDActionHeaderView *actionHeader;

@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic,retain) IBOutlet NSMutableDictionary *bill;

- (IBAction)resetTableData:(id)sender;

- (IBAction)starButtonToggle:(id)sender;

@end
