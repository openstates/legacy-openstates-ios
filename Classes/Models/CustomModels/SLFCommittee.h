#import "_SLFCommittee.h"

@class RKManagedObjectMapping;
@class SLFState;
@class SLFChamber;
@interface SLFCommittee : _SLFCommittee {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) SLFChamber *chamberObj;
@property (nonatomic,readonly) NSString *chamberShortName;
@property (nonatomic,readonly) NSString *fullName;

- (NSArray *)sortedMembers;
+ (NSArray *)sortDescriptors;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSString *)resourcePathForAllWithStateID:(NSString *)stateID;

@end
