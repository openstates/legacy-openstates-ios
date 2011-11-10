#import "SLFDataModels.h"

@implementation SLFCommittee

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    mapping.primaryKeyAttribute = @"committeeID";
    [mapping mapKeyPath:@"id" toAttribute:@"committeeID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"parent_id" toAttribute:@"parentID"];
    [mapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [mapping mapKeyPath:@"committee" toAttribute:@"committeeName"];
    [mapping mapAttributes:@"chamber", @"subcommittee", nil];
    return mapping;
}

#pragma mark -
#pragma mark Relationship Mapping

+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping {
    RKManagedObjectMapping *mapping = [[self class] mapping];
    [mapping connectStateToKeyPath:@"stateObj" withStateMapping:stateMapping];
    return mapping;
}

// This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

#pragma mark -
#pragma mark Display Convenience

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.state];
}

- (NSString *)chamberShortName {
    return self.chamberObj.shortName;
}

- (NSString *) initial {
	return [self.committeeName substringToIndex:1];
}

- (NSArray *)sortedMembers
{    
    if (!self.members)
        return nil;
    return [self.members sortedArrayUsingDescriptors:[CommitteeMember sortDescriptors]];
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [NSSortDescriptor sortDescriptorWithKey:@"committeeName" ascending:YES];
    NSSortDescriptor *chamberDesc = [NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, chamberDesc, nil];
}
@end
