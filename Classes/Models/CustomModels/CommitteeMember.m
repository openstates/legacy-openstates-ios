#import "CommitteeMember.h"
#import "SLFLegislator.h"
#import <RestKit/CoreData/CoreData.h>

@implementation CommitteeMember

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapAttributes:@"type", @"name", nil];
    return mapping;
}

- (SLFLegislator *)foundLegislator {
    if (!self.legID)
        return nil;
    return [SLFLegislator findFirstByAttribute:@"legID" withValue:self.legID];
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
    NSSortDescriptor *roleDesc = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
    NSSortDescriptor *nameDesc = [NSSortDescriptor sortDescriptorWithKey:@"foundLegislator.lastName" ascending:YES];
    return [NSArray arrayWithObjects:roleDesc, nameDesc, nil];
}

@end
