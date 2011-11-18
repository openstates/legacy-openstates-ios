#import "_GenericAsset.h"

@class RKManagedObjectMapping;
@interface GenericAsset : _GenericAsset {}
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
