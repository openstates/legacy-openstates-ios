#import "CommitteeRole.h"
#import "SLFCommittee.h"
#import "SLFSortDescriptor.h"
#import <RestKit/CoreData/CoreData.h>

@implementation CommitteeRole

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    [mapping mapKeyPath:@"committee_id" toAttribute:@"committeeID"];
    [mapping mapKeyPath:@"committee" toAttribute:@"name"];
    [mapping mapAttributes:@"type", @"chamber", nil];
    return mapping;
}

- (SLFCommittee *)foundCommittee {
    if (!self.committeeID)
        return nil;
    return [SLFCommittee findFirstByAttribute:@"committeeID" withValue:self.committeeID];
}

- (NSString *)type {
    [self willAccessValueForKey:@"type"];
    NSString *aRole = [self primitiveValueForKey:@"type"];
    [self didAccessValueForKey:@"type"];
    if (aRole)
        aRole = [aRole capitalizedString];
    return aRole;
}

+ (NSArray *)sortDescriptors {
    NSArray *existing = [[self superclass] sortDescriptors];
    NSMutableArray *descriptors = [NSMutableArray arrayWithArray:existing];
    [descriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES]];
    return descriptors;
}

@end
