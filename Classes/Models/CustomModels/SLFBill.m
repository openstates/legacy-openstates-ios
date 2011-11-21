#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import "BillActionParser.h"

@implementation SLFBill

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    mapping.primaryKeyAttribute = @"billID";
    [mapping mapKeyPath:@"bill_id" toAttribute:@"billID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapAttributes:@"session", @"chamber",@"title",  nil];
    return mapping;
}

#pragma mark - Relationship Mapping

+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping {
    RKManagedObjectMapping *mapping = [[self class] mapping];
    [mapping connectStateToKeyPath:@"stateObj" withStateMapping:stateMapping];
    return mapping;
}

// This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.state];
}

#pragma mark - Convenience Methods

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *stateDesc = [NSSortDescriptor sortDescriptorWithKey:@"stateID" ascending:YES];
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *sessionDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"session" ascending:NO options:options];
//  NSSortDescriptor *chamberDesc = [NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES];
    NSSortDescriptor *billIDDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"billID" ascending:YES options:options];
    return [NSArray arrayWithObjects:stateDesc, sessionDesc, billIDDesc, nil];
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ (%@)", self.billID, [self.stateID uppercaseString]];
}

- (NSString *)title {
    [self willAccessValueForKey:@"title"];
    NSString *value = [self primitiveTitle];
    [self didAccessValueForKey:@"title"];
    if (value)
        value = [value capitalizedString];
    return value;
}

- (NSArray *)sortedActions {
    if (IsEmpty(self.actions))
        return nil;
   return [self.actions sortedArrayUsingDescriptors:[BillAction sortDescriptors]];
}

- (NSArray *)sortedVotes {
    if (IsEmpty(self.votes))
        return nil;
    return [self.votes sortedArrayUsingDescriptors:[BillRecordVote sortDescriptors]];
}

- (NSArray *)sortedSponsors {
    if (IsEmpty(self.sponsors))
        return nil;
    return [self.sponsors sortedArrayUsingDescriptors:[BillSponsor sortDescriptors]];
}

- (NSArray *)sortedSubjects {
    if (IsEmpty(self.subjects))
        return nil;
    return [self.subjects sortedArrayUsingDescriptors:[GenericWord sortDescriptors]];
}

#pragma mark - Bill Stages and Bill Types

- (BillType)billType {
    __block BillType billType = BillTypeInvalid;
    if (!IsEmpty(self.types)) {
        [self.types enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if ([obj isKindOfClass:[GenericWord class]]) {
                NSString *word = [[obj word] lowercaseString];
                if ([@"bill" isEqual:word])
                    billType = BillTypeBill;
                else if ([@"concurrent resolution" isEqual:word])
                    billType = BillTypeConcurrentResolution;
                else if ([@"joint resolution" isEqual:word])
                    billType = BillTypeJointResolution;
                else if ([@"resolution" isEqual:word])
                    billType = BillTypeJointResolution;
                if (billType != BillTypeInvalid)
                    *stop = YES;
            }
        }];
    }
    if (billType == BillTypeInvalid) 
        billType = BillTypeSimpleResolution; // default
    return billType;
}

- (NSArray *)stages {
    if (IsEmpty(self.actions))
        return nil;
    BillActionParser *parser = [[BillActionParser alloc] init];
    NSArray *stages = [parser stagesForBill:self];
    [parser release];
    return stages;
}
@end
