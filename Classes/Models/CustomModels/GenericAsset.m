#import "GenericAsset.h"
#import "SLFSortDescriptor.h"
#import <SLFRestKit/CoreData.h>

@implementation GenericAsset

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    [mapping mapAttributes:@"name", @"url", nil];
    return mapping;
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *urlDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"url" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, urlDesc, nil];
}

- (NSString *)fileName {
    if (SLFTypeNonEmptyStringOrNil(self.url)) {
        return [self.url lastPathComponent];
    }
    return @"";
}
@end
