#import "GenericNamedItem.h"
#import "SLFSortDescriptor.h"

@implementation GenericNamedItem

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *typeDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"type" ascending:YES];
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES];
    return [NSArray arrayWithObjects:typeDesc, nameDesc, nil];
}

@end
