#import <RestKit/CoreData/CoreData.h>
#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import "NSDate+SLFDateHelper.h"

@implementation BillRecordVote

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[BillRecordVote class]];
    mapping.primaryKeyAttribute = @"voteID";
    [mapping mapAttributes:@"date", @"type", @"chamber", @"passed", @"session", @"motion", nil];
    [mapping mapKeyPath:@"vote_id" toAttribute:@"voteID"];
    [mapping mapKeyPath:@"+state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"+record" toAttribute:@"record"];
    [mapping mapKeyPath:@"+method" toAttribute:@"method"];
    [mapping mapKeyPath:@"yes_count" toAttribute:@"yesCount"];
    [mapping mapKeyPath:@"no_count" toAttribute:@"noCount"];
    [mapping mapKeyPath:@"other_count" toAttribute:@"otherCount"];
    [mapping mapKeyPath:@"bill_chamber" toAttribute:@"billChamber"];
    mapping.setNilForMissingRelationships = NO;
    return mapping;
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSSortDescriptor *billIDDesc = [NSSortDescriptor sortDescriptorWithKey:@"billID" ascending:YES];
    NSSortDescriptor *actionIDDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"actionID" ascending:NO options:options];
    NSSortDescriptor *actionDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"action" ascending:YES options:options];
    NSSortDescriptor *actorDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"actor" ascending:YES options:options];
    return [NSArray arrayWithObjects:dateDesc, billIDDesc, actionIDDesc, actionDesc, actorDesc, nil];
}

- (SLFState *)state {
    return self.bill.state;
}

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.state];
}

- (NSString *)title {
    return [NSString stringWithFormat:@"%@ - %@ (%@)", [self.date stringForDisplay], self.chamberObj.shortName, [self.motion capitalizedString]];
}

- (NSString *)subtitle {
    NSString *passage = NSLocalizedString(@"Failed",@"");
    if (self.passedValue == YES)
        passage = NSLocalizedString(@"Passed",@"");
    return [NSString stringWithFormat:@"%@ (%@-%@-%@)", passage, self.yesCount, self.noCount, self.otherCount];
}
@end
