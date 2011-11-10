#import "GenericWord.h"
#import <RestKit/CoreData/CoreData.h>

@implementation GenericWord

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"" toAttribute:@"word"];
    return mapping;
}

@end
