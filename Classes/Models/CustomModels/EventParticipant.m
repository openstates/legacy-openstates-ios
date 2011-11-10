#import "EventParticipant.h"
#import <RestKit/CoreData/CoreData.h>

@implementation EventParticipant

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"name", @"type", nil];
    return mapping;
}

@end
