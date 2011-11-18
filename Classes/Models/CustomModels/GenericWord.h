#import "_GenericWord.h"

@class RKManagedObjectMapping;
@interface GenericWord : _GenericWord {}
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
