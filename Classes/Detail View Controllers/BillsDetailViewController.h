//
//  BillsDetailViewController.h
//  Created by Gregory Combs on 2/20/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@class TableCellDataObject;
@class DDActionHeaderView;
@class BillVotesDataSource;
@class AppendingFlowView;
@interface BillsDetailViewController : UITableViewController <RKRequestDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate> {
	BillVotesDataSource *voteDS;
}
@property (nonatomic,assign) id dataObject;
@property (nonatomic,retain) UIButton *starButton;

@property (nonatomic,retain) IBOutlet UIView *headerView, *descriptionView;
@property (nonatomic,retain) IBOutlet AppendingFlowView *statusView;
@property (nonatomic,retain) IBOutlet UITextView *lab_description;
@property (nonatomic,retain) IBOutlet DDActionHeaderView *actionHeader;

@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic,retain) NSMutableDictionary *bill;

- (IBAction)starButtonToggle:(id)sender;

@end
