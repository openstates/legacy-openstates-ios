//
//  NSString+SLFExtensions.m
//  Created by Greg Combs on 11/20/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "NSString+SLFExtensions.h"

@implementation NSString (SLFExtensions)

- (BOOL)hasSubstring:(NSString *)search caseInsensitive:(BOOL)caseInsensitive {
    if (!SLFTypeNonEmptyStringOrNil(search))
        return NO;
    NSString *string = self;
    if (caseInsensitive) {
        string = [string lowercaseString];
        search = [search lowercaseString];
    }
    return [string rangeOfString:search].length > 0;
}

- (BOOL)hasSubstring:(NSString *)search {
    return [self hasSubstring:search caseInsensitive:NO];
}

- (BOOL)isEqualToString:(NSString *)aString caseInsensitive:(BOOL)caseInsensitive {
    NSString *string = self;
    if (caseInsensitive) {
        string = [string lowercaseString];
        aString = [aString lowercaseString];
    }
    return [string isEqualToString:aString];
}

@end
