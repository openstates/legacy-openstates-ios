#import "_GenericAsset.h"

@class RKManagedObjectMapping;
@interface GenericAsset : _GenericAsset {}
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@property (nonatomic,readonly) NSString *fileName;
@end
