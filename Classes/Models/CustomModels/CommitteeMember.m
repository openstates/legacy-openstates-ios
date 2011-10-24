#import "SLFDataModels.h"

@implementation CommitteeMember
@dynamic legID;
@dynamic legislatorName;
@dynamic role;
@dynamic committeeInverse;

- (SLFLegislator *)foundLegislator {
    if (!self.legID)
        return nil;
    return [SLFLegislator findFirstByAttribute:@"legID" withValue:self.legID];
}

- (NSString *)role {
    [self willAccessValueForKey:@"role"];
    NSString *aRole = [self primitiveValueForKey:@"role"];
    [self didAccessValueForKey:@"role"];
    if (aRole)
        aRole = [aRole capitalizedString];
    return aRole;
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *roleDesc = [NSSortDescriptor sortDescriptorWithKey:@"role" ascending:YES];
    NSSortDescriptor *nameDesc = [NSSortDescriptor sortDescriptorWithKey:@"foundLegislator.lastName" ascending:YES];
    return [NSArray arrayWithObjects:roleDesc, nameDesc, nil];
}

@end
