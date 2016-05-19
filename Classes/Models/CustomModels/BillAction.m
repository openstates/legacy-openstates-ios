#import "SLFDataModels.h"
#import <SLFRestKit/CoreData.h>
#import "SLFSortDescriptor.h"
#import "NSDate+SLFDateHelper.h"

@implementation BillAction

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    [mapping mapAttributes:@"date", @"action", @"actor", nil];
    [mapping mapKeyPath:@"+action_number" toAttribute:@"actionID"];
    [mapping mapKeyPath:@"+comment" toAttribute:@"comment"];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSSortDescriptor *billIDDesc = [SLFSortDescriptor sortDescriptorWithKey:@"bill.billID" ascending:YES];
    NSSortDescriptor *actionIDDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"actionID" ascending:NO];
    NSSortDescriptor *actionDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"action" ascending:YES];
    NSSortDescriptor *actorDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"actor" ascending:YES];
    return [NSArray arrayWithObjects:dateDesc, billIDDesc, actionIDDesc, actionDesc, actorDesc, nil];
}

- (NSString *)action {
    [self willAccessValueForKey:@"action"];
    NSString *actionValue = [self primitiveAction];
    [self didAccessValueForKey:@"action"];
    if (actionValue)
        actionValue = [actionValue capitalizedString];
    return actionValue;
}

- (NSString *)title {
    NSString *dateString = [self.date stringForDisplay];
    return [NSString stringWithFormat:@"%@ - %@", dateString, self.action];
}

- (NSString *)subtitle {
    SLFChamber *chamber = [SLFChamber chamberWithType:self.actor forState:self.bill.state];
    NSString *actorName = [self.actor capitalizedString];
    if (chamber)
        actorName = chamber.shortName;
    NSMutableString *words = [NSMutableString stringWithFormat:@"(%@) ", actorName];
    if (SLFTypeNonEmptyStringOrNil(self.actionID))
        [words appendFormat:@"- %@ ",self.actionID];
    if (SLFTypeNonEmptyStringOrNil(self.comment))
        [words appendFormat:@"- %@ ",self.comment];
    return words;
}
@end
