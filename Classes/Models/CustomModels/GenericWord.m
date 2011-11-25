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
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"word" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, nil];
}

- (NSString *)description {
    return self.word;
}
@end
