#import "GenericNamedItem.h"
#import "SLFSortDescriptor.h"

@implementation GenericNamedItem

+ (NSArray *)sortDescriptors {
    NSStringCompareOptions options = NSNumericSearch | NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSSortDescriptor *typeDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"type" ascending:YES options:options];
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES options:options];
    return [NSArray arrayWithObjects:typeDesc, nameDesc, nil];
}

@end
