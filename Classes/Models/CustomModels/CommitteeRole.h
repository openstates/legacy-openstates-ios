#import "_CommitteeRole.h"

@class SLFCommittee;
@class RKManagedObjectMapping;
@interface CommitteeRole : _CommitteeRole {}
@property (nonatomic, readonly) SLFCommittee *foundCommittee;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
