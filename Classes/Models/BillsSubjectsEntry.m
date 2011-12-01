//
//  BillsSubjectsEntry.m
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
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

- (void)dealloc {
    self.name = nil;
    self.billCount = nil;
    [super dealloc];
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.billCount];
}
@end
