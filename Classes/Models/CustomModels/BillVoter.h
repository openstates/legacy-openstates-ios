#import "_BillVoter.h"

@class RKManagedObjectMapping;
@interface BillVoter : _BillVoter {}
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
