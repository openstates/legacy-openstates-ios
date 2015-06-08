//
//  BillDetailViewController.h
//  Created by Gregory Combs on 2/20/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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
