//
//  BillDetailViewController.h
//  Created by Gregory Combs on 2/20/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"
#import "SLFImprovedRKTableController.h"

@class SLFBill;
@class SLFState;

@interface BillDetailViewController : SLFTableViewController <RKObjectLoaderDelegate>

@property (nonatomic, retain) SLFBill *bill;
@property (nonatomic,retain) SLFImprovedRKTableController *tableController;

- (id)initWithState:(SLFState *)aState session:(NSString *)aSession billID:(NSString *)billID;
- (id)initWithBill:(SLFBill *)aBill;

@end
