#import "CommitteeMember.h"
#import "SLFLegislator.h"
#import <RestKit/CoreData/CoreData.h>
#import "SLFSortDescriptor.h"

@implementation CommitteeMember

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapAttributes:@"type", @"name", nil];
    return mapping;
}

- (SLFLegislator *)foundLegislator {
    if (!self.legID)
        return nil;
    return [SLFLegislator findFirstByAttribute:@"legID" withValue:self.legID];
}

- (NSString *)type {
    [self willAccessValueForKey:@"type"];
    NSString *aRole = [self primitiveValueForKey:@"type"];
    [self didAccessValueForKey:@"type"];
    if (aRole)
        aRole = [aRole capitalizedString];
    return aRole;
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSArray *existing = [[self superclass] sortDescriptors];
    NSMutableArray *descriptors = [NSMutableArray arrayWithArray:existing];
    [descriptors insertObject:[SLFSortDescriptor stringSortDescriptorWithKey:@"foundLegislator.lastName" ascending:YES options:options] atIndex:1];
    return descriptors;
}

@end
