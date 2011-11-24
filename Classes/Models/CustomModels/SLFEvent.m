#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"

@implementation SLFEvent

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    mapping.primaryKeyAttribute = @"eventID";
    [mapping mapKeyPath:@"id" toAttribute:@"eventID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"when" toAttribute:@"dateStart"];
    [mapping mapKeyPath:@"end" toAttribute:@"dateEnd"];
    [mapping mapKeyPath:@"description" toAttribute:@"eventDescription"];
    [mapping mapKeyPath:@"+link" toAttribute:@"link"];
    [mapping mapAttributes:@"session", @"type", @"location",  nil];
    return mapping;
}

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
    return [NSArray arrayWithObjects:@"eventDescription", @"location", nil];
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:@"dateStart" ascending:YES];
    NSSortDescriptor *stateDesc = [NSSortDescriptor sortDescriptorWithKey:@"stateID" ascending:YES];
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"description" ascending:YES options:options];
    return [NSArray arrayWithObjects:dateDesc, stateDesc, nameDesc, nil];
}


@end
