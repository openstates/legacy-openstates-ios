//
//  BillDetailViewController.h
//  Created by Gregory Combs on 2/20/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"

@class SLFBill;
@class SLFState;
    //@class DDActionHeaderView;
    //@class AppendingFlowView;

@interface BillDetailViewController : SLFTableViewController <RKObjectLoaderDelegate>
@property (nonatomic, retain) SLFBill *bill;
/*
@property (nonatomic,retain) UIButton *starButton;
@property (nonatomic,retain) IBOutlet UIView *headerView, *descriptionView;
@property (nonatomic,retain) IBOutlet AppendingFlowView *statusView;
@property (nonatomic,retain) IBOutlet UITextView *lab_description;
@property (nonatomic,retain) IBOutlet DDActionHeaderView *actionHeader;
 - (IBAction)starButtonToggle:(id)sender;
 */
- (id)initWithBillID:(NSString *)billID state:(SLFState *)aState session:(NSString *)aSession;
- (id)initWithBill:(SLFBill *)aBill;
@end
