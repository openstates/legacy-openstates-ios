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
        
        if (!SLFTypeIsNull([aDictionary valueForKey:@"entryValue"]))
            self.entryValue = [aDictionary valueForKey:@"entryValue"];
        if (!SLFTypeIsNull([aDictionary valueForKey:@"entryType"]))
            self.entryType = [[aDictionary valueForKey:@"entryType"] integerValue];        
        if (!SLFTypeIsNull([aDictionary valueForKey:@"isClickable"]))
            self.isClickable = [[aDictionary valueForKey:@"isClickable"] boolValue];
        if (SLFTypeNonEmptyStringOrNil([aDictionary valueForKey:@"title"]))
            self.title = [aDictionary valueForKey:@"title"];
        if (SLFTypeNonEmptyStringOrNil([aDictionary valueForKey:@"subtitle"]))
            self.subtitle = [aDictionary valueForKey:@"subtitle"];
        if (!SLFTypeIsNull([aDictionary valueForKey:@"action"]))
            self.action = [aDictionary valueForKey:@"action"];
        if (!SLFTypeIsNull([aDictionary valueForKey:@"parameter"]))
            self.parameter = [aDictionary valueForKey:@"parameter"];
    }
    return self;
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
