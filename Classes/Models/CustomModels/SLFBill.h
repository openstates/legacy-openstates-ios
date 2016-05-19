#import "_SLFBill.h"

typedef enum BillType {
	BillTypeInvalid = -1,
	BillTypeSimpleResolution = 0,	// Stages 1-3 (2 is optional)
	BillTypeConcurrentResolution,	// Stages 1-5, 6&7 optional/unknown
	BillTypeJointResolution,		// Stages 1-5, 6 (sec of state), 7 (after voter approval)
	BillTypeBill,					// Stages 1-7
} BillType;

@class RKManagedObjectMapping;
@class SLFState;
@class SLFChamber;
@interface SLFBill : _SLFBill {}
@property (weak, nonatomic,readonly) SLFState *state;
@property (weak, nonatomic,readonly) SLFChamber *chamberObj;
@property (weak, nonatomic,readonly) NSString *name;
@property (weak, nonatomic,readonly) NSArray *sortedActions;
@property (weak, nonatomic,readonly) NSArray *sortedVotes;
@property (weak, nonatomic,readonly) NSArray *sortedSponsors;
@property (weak, nonatomic,readonly) NSArray *sortedSubjects;
@property (weak, nonatomic,readonly) NSArray *stages;
@property (nonatomic,readonly) BillType billType;
@property (weak, nonatomic,readonly) NSString *watchID;
@property (weak, nonatomic,readonly) NSString *watchSummaryForDisplay;
+ (SLFBill *)billForWatchID:(NSString *)watchID;
+ (NSString *)resourcePathForWatchID:(NSString *)watchID;
+ (NSString *)watchIDForResourcePath:(NSString *)resourcePath;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
@end
