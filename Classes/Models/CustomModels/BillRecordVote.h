#import "_BillRecordVote.h"

@class SLFChamber;
@class SLFState;
@class RKManagedObjectMapping;
@interface BillRecordVote : _BillRecordVote {}
@property (weak, nonatomic,readonly) SLFState *state;
@property (weak, nonatomic,readonly) SLFChamber *chamberObj;
@property (weak, nonatomic,readonly) NSString *title;
@property (weak, nonatomic,readonly) NSString *subtitle;
@property (weak, nonatomic,readonly) NSArray *sortedYesVotes;
@property (weak, nonatomic,readonly) NSArray *sortedNoVotes;
@property (weak, nonatomic,readonly) NSArray *sortedOtherVotes;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
