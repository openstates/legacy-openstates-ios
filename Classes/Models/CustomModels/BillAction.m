#import "BillAction.h"
#import <RestKit/CoreData/CoreData.h>

@implementation BillAction

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"date", @"action", @"actor", nil];
    [mapping mapKeyPath:@"+action_number" toAttribute:@"actionID"];
    [mapping mapKeyPath:@"+comment" toAttribute:@"comment"];
    return mapping;
}

@end
