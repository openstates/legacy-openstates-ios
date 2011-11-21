#import "_BillRecordVote.h"

@class SLFChamber;
@class SLFState;
@class RKManagedObjectMapping;
@interface BillRecordVote : _BillRecordVote {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) SLFChamber *chamberObj;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) NSString *subtitle;
@property (nonatomic,readonly) NSArray *sortedYesVotes;
@property (nonatomic,readonly) NSArray *sortedNoVotes;
@property (nonatomic,readonly) NSArray *sortedOtherVotes;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
