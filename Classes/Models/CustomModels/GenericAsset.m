#import "GenericAsset.h"
#import <RestKit/CoreData/CoreData.h>

@implementation GenericAsset

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"name", @"url", nil];
    return mapping;
}

@end
