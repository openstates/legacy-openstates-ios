#import "_CommitteeMember.h"

@class SLFLegislator;
@class RKManagedObjectMapping;
@interface CommitteeMember : _CommitteeMember {}
@property (nonatomic, readonly) SLFLegislator *foundLegislator;
+ (NSArray *)sortDescriptors;
+ (RKManagedObjectMapping *)mapping;
@end
