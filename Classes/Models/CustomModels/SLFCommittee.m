#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@implementation SLFCommittee

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
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

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"committeeName" ascending:YES];
    NSSortDescriptor *chamberDesc = [NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, chamberDesc, nil];
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

+ (NSArray*)searchableAttributes {
    return [NSArray arrayWithObjects:@"committeeName", nil];
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

+ (NSString *)resourcePathForAllWithStateID:(NSString *)stateID {
    /* download just enough attributes to populate the cell. */
    return [NSString stringWithFormat:@"/committees?state=%@&apikey=%@&fields=state,chamber,id,committee", stateID, SUNLIGHT_APIKEY];
}

@end
