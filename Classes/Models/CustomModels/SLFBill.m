#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import "BillActionParser.h"
#import "BillSearchParameters.h"
#import "NSDate+SLFDateHelper.h"
#import <SLFRestKit/RestKit.h>
#import <SLFRestKit/CoreData.h>

@implementation SLFBill

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
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

+ (NSArray*)searchableAttributes {
    return [NSArray arrayWithObjects:@"title", @"billID", nil];
}

#pragma mark - Convenience Methods

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *sessionDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"session" ascending:NO];
    NSSortDescriptor *billIDDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"billID" ascending:YES];
    return [NSArray arrayWithObjects:sessionDesc, billIDDesc, nil];
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ (%@)", self.billID, [self.state displayNameForSession:self.session]];
}

- (NSString *)title {
    [self willAccessValueForKey:@"title"];
    NSString *value = [self primitiveTitle];
    [self didAccessValueForKey:@"title"];
    if (value)
        value = [value capitalizedString];
    return value;
}

- (NSString *)watchSummaryForDisplay {
    return [NSString stringWithFormat:NSLocalizedString(@"Updated %@ - %@",@""), [self.dateUpdated stringForDisplayWithPrefix:YES], self.title];
}

#pragma mark - Bill Watch

- (NSString *)watchID {
    return RKMakePathWithObjectAddingEscapes(@":stateID||:session||:billID", self, NO);
}

+ (NSArray *)billComponentsForWatchID:(NSString *)watchID {
    if (!SLFTypeNonEmptyStringOrNil(watchID))
        return nil;
    NSArray *parts = [watchID componentsSeparatedByString:@"||"];
    if (parts.count < 3)
        return nil;
    return parts;
}

+ (SLFBill *)billForWatchID:(NSString *)watchID {
    NSArray *parts = [SLFBill billComponentsForWatchID:watchID];
    if (!parts)
        return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stateID = %@ AND session = %@ AND billID = %@", [parts objectAtIndex:0], [parts objectAtIndex:1], [parts objectAtIndex:2]];
    SLFBill *bill = [SLFBill findFirstWithPredicate:predicate];
    return bill;
}

+ (NSString *)resourcePathForWatchID:(NSString *)watchID {
    NSArray *parts = [SLFBill billComponentsForWatchID:watchID];
    if (!parts)
        return nil;
    return [BillSearchParameters pathForBill:[parts objectAtIndex:2] state:[parts objectAtIndex:0] session:[parts objectAtIndex:1]];
}

+ (NSString *)watchIDForResourcePath:(NSString *)resourcePath {
    if (!SLFTypeNonEmptyStringOrNil(resourcePath))
        return nil;
    RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];
    NSDictionary *args = nil;
    if ([pathMatcher matchesPattern:@"/bills/:stateID/:session/:billID" tokenizeQueryStrings:YES parsedArguments:&args]) {
        return RKMakePathWithObjectAddingEscapes(@":stateID||:session||:billID", args, NO);
    }
    return nil;
}

#pragma mark - Sorted Collections

- (NSArray *)sortedActions {
    if (!SLFTypeNonEmptySetOrNil(self.actions))
        return nil;
   return [self.actions sortedArrayUsingDescriptors:[BillAction sortDescriptors]];
}

- (NSArray *)sortedVotes {
    if (!SLFTypeNonEmptySetOrNil(self.votes))
        return nil;
    return [self.votes sortedArrayUsingDescriptors:[BillRecordVote sortDescriptors]];
}

- (NSArray *)sortedSponsors {
    if (!SLFTypeNonEmptySetOrNil(self.sponsors))
        return nil;
    return [self.sponsors sortedArrayUsingDescriptors:[BillSponsor sortDescriptors]];
}

- (NSArray *)sortedSubjects {
    if (!SLFTypeNonEmptySetOrNil(self.subjects))
        return nil;
    return [self.subjects sortedArrayUsingDescriptors:[GenericWord sortDescriptors]];
}

#pragma mark - Bill Stages and Bill Types

- (BillType)billType {
    __block BillType billType = BillTypeInvalid;
    if (SLFTypeNonEmptySetOrNil(self.types)) {
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
    if (!SLFTypeNonEmptySetOrNil(self.actions))
        return nil;
    BillActionParser *parser = [[BillActionParser alloc] init];
    NSArray *stages = [parser stagesForBill:self];
    return stages;
}

/* This is unnecessary, since resource paths are generated in the BillSearchParameters class. "fields" added in BillsViewController
+ (NSString *)resourcePathForAllWithStateID:(NSString *)stateID {
    return nil;
}
*/

@end
