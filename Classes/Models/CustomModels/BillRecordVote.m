#import <SLFRestKit/CoreData.h>
#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import "NSDate+SLFDateHelper.h"

@implementation BillRecordVote

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[BillRecordVote class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
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
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSSortDescriptor *billIDDesc = [SLFSortDescriptor sortDescriptorWithKey:@"bill.billID" ascending:YES];
    NSSortDescriptor *voteIDDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"voteID" ascending:YES];
    NSSortDescriptor *chamberDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"chamber" ascending:YES];
    return [NSArray arrayWithObjects:dateDesc, billIDDesc, voteIDDesc, chamberDesc, nil];
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

- (NSArray *)sortedYesVotes
{    
    if (!self.yesVotes)
        return nil;
    return [self.yesVotes sortedArrayUsingDescriptors:[BillVoter sortDescriptors]];
}

- (NSArray *)sortedNoVotes
{    
    if (!self.noVotes)
        return nil;
    return [self.noVotes sortedArrayUsingDescriptors:[BillVoter sortDescriptors]];
}

- (NSArray *)sortedOtherVotes
{    
    if (!self.otherVotes)
        return nil;
    return [self.otherVotes sortedArrayUsingDescriptors:[BillVoter sortDescriptors]];
}

@end
