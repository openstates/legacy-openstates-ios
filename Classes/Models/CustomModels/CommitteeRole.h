#import "_CommitteeRole.h"

@class SLFCommittee;
@class RKManagedObjectMapping;
@interface CommitteeRole : _CommitteeRole {}
@property (weak, nonatomic, readonly) SLFCommittee *foundCommittee;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
