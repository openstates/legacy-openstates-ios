#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFBill.h"

@class SLFState;
@interface SLFBill : _SLFBill {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) NSString *watchID;
@end

enum kBillStages {
	BillStageUnknown = 0,
	BillStageFiled,
	BillStageOutOfCommittee,
	BillStageChamberVoted,
	BillStageOutOfOpposingCommittee,
	BillStageOpposingChamberVoted,
	BillStageSentToGovernor,
	BillStageBecomesLaw,
	BillStageVetoed = -1
};

/*
 1. Filed
 2. Out of (current chamber) Committee
 3. Voted on by (current chamber)
 4. Out of (opposing chamber) Committee
 5. Voted on by (opposing chamber)
 6. Submitted to Governor
 7. Bill Becomes Law
-1. Vetoed
 */

BOOL billTypeRequiresGovernor(NSString *billType);
BOOL billTypeRequiresOpposingChamber(NSString *billType);
