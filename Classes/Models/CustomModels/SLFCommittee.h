#import "_SLFCommittee.h"

@class RKManagedObjectMapping;
@class SLFState;
@class SLFChamber;
@interface SLFCommittee : _SLFCommittee {}
@property (weak, nonatomic,readonly) SLFState *state;
@property (weak, nonatomic,readonly) SLFChamber *chamberObj;
@property (weak, nonatomic,readonly) NSString *chamberShortName;
@property (weak, nonatomic,readonly) NSString *fullName;

- (NSArray *)sortedMembers;
+ (NSArray *)sortDescriptors;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSString *)resourcePathForAllWithStateID:(NSString *)stateID;

@end
