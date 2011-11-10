#import "BillRecordVote.h"
#import <RestKit/CoreData/CoreData.h>

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

@end
