#import "CommitteeRole.h"
#import "SLFCommittee.h"
#import <RestKit/CoreData/CoreData.h>

@implementation CommitteeRole

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[self class]];
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
    NSSortDescriptor *nameDesc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *chamberDesc = [NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, chamberDesc, nil];
}

@end
