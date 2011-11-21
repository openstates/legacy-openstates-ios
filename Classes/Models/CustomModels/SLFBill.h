#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFBill.h"

typedef enum BillType {
	BillTypeInvalid = -1,
	BillTypeSimpleResolution = 0,	// Stages 1-3 (2 is optional)
	BillTypeConcurrentResolution,	// Stages 1-5, 6&7 optional/unknown
	BillTypeJointResolution,		// Stages 1-5, 6 (sec of state), 7 (after voter approval)
	BillTypeBill,					// Stages 1-7
} BillType;

@class SLFState;
@class SLFChamber;
@interface SLFBill : _SLFBill {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) SLFChamber *chamberObj;
@property (nonatomic,readonly) NSString *name;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
@property (nonatomic,readonly) NSArray *sortedActions;
@property (nonatomic,readonly) NSArray *sortedVotes;
@property (nonatomic,readonly) NSArray *sortedSponsors;
@property (nonatomic,readonly) NSArray *sortedSubjects;
@property (nonatomic,readonly) BillType billType;
@property (nonatomic,readonly) NSArray *stages;
@end
