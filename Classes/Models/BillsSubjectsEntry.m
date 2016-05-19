//
//  BillsSubjectsEntry.m
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <SLFRestKit/RestKit.h>
#import "BillsSubjectsEntry.h"
#import "SLFSortDescriptor.h"

@implementation BillsSubjectsEntry
@synthesize name = _name;
@synthesize billCount = _billCount;

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[BillsSubjectsEntry class]];
    mapping.forceCollectionMapping = YES;
    [mapping mapKeyOfNestedDictionaryToAttribute:@"name"];    
    RKObjectAttributeMapping* countMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"(name)" toKeyPath:@"billCount"];
    [mapping addAttributeMapping:countMapping];
    return mapping;
}


+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.billCount];
}
@end
