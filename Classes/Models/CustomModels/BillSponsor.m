#import "BillSponsor.h"
#import <RestKit/CoreData/CoreData.h>

@implementation BillSponsor

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapAttributes:@"type", @"name", nil];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    return [[self superclass] sortDescriptors];
}

@end
