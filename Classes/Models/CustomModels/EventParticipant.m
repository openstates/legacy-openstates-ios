#import "EventParticipant.h"
#import <SLFRestKit/CoreData.h>

@implementation EventParticipant

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    [mapping mapAttributes:@"type", nil];
    [mapping mapKeyPath:@"participant" toAttribute:@"name"];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    return [[self superclass] sortDescriptors];
}

- (void)setType:(NSString *)type {
    [self willChangeValueForKey:@"type"];
    if (SLFTypeNonEmptyStringOrNil(type))
        type = [type capitalizedString];
    [self setPrimitiveType:type];
    [self didChangeValueForKey:@"type"];
}
@end
