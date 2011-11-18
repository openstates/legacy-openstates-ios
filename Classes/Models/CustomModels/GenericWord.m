#import "GenericWord.h"
#import "SLFSortDescriptor.h"
#import <RestKit/CoreData/CoreData.h>

@implementation GenericWord

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"" toAttribute:@"word"];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"word" ascending:YES options:options];
    return [NSArray arrayWithObjects:nameDesc, nil];
}

@end
