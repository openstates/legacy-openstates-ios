#import "GenericAsset.h"
#import "SLFSortDescriptor.h"
#import <RestKit/CoreData/CoreData.h>

@implementation GenericAsset

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapAttributes:@"name", @"url", nil];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES options:options];
    NSSortDescriptor *urlDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"url" ascending:YES options:options];
    return [NSArray arrayWithObjects:nameDesc, urlDesc, nil];
}

@end
