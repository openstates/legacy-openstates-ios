#import "_BillRecordVote.h"

@class SLFChamber;
@class SLFState;
@class RKManagedObjectMapping;
@interface BillRecordVote : _BillRecordVote {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) SLFChamber *chamberObj;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) NSString *subtitle;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
