#import "BillSponsor.h"
#import <RestKit/CoreData/CoreData.h>

@implementation BillSponsor

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapAttributes:@"type", @"name", nil];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    return [[self superclass] sortDescriptors];
}

@end
