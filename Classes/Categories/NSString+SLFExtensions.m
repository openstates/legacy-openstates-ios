//
//  NSString+SLFExtensions.m
//  Created by Greg Combs on 11/20/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "NSString+SLFExtensions.h"

@implementation NSString (SLFExtensions)

- (BOOL)hasSubstring:(NSString *)search caseInsensitive:(BOOL)caseInsensitive {
    if (IsEmpty(search))
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
