//
//  TableCellDataObject.m
//  Created by Gregory S. Combs on 5/31/09.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "TableCellDataObject.h"

@implementation TableCellDataObject
@synthesize entryValue, isClickable, entryType, title, subtitle, action, parameter;
@synthesize indexPath;

- (id)initWithDictionary:(NSDictionary *)aDictionary {
    if ((self = [super init])) {
        
        if (!IsEmpty([aDictionary valueForKey:@"entryValue"]))
            self.entryValue = [aDictionary valueForKey:@"entryValue"];
        if (!IsEmpty([aDictionary valueForKey:@"entryType"]))
            self.entryType = [[aDictionary valueForKey:@"entryType"] integerValue];        
        if (!IsEmpty([aDictionary valueForKey:@"isClickable"]))
            self.isClickable = [[aDictionary valueForKey:@"isClickable"] boolValue];
        if (!IsEmpty([aDictionary valueForKey:@"title"]))
            self.title = [aDictionary valueForKey:@"title"];
        if (!IsEmpty([aDictionary valueForKey:@"subtitle"]))
            self.subtitle = [aDictionary valueForKey:@"subtitle"];
        if (!IsEmpty([aDictionary valueForKey:@"action"]))
            self.action = [aDictionary valueForKey:@"action"];
        if (!IsEmpty([aDictionary valueForKey:@"parameter"]))
            self.parameter = [aDictionary valueForKey:@"parameter"];
    }
    return self;
}


- (void)dealloc {
    self.entryValue = self.subtitle = self.title = nil;
    self.parameter = nil;
    self.action = nil;
    self.indexPath = nil;
    
    [super dealloc];
}

- (NSString *)description {
    return [[self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:
                                              @"title",
                                              @"subtitle",
                                              @"entryValue",
                                              @"entryType",
                                              @"isClickable",
                                              @"action",
                                              @"parameter",
                                              @"indexPath",
                                               nil]] description];
}

@end
