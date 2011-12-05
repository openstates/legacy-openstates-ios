//
//  SLFTestFlight.m
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTestFlight.h"
#import "TestFlight.h"

    //#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    //#define RKLogDebug(__FORMAT__, ...) TFLog((@"RKLogDebug - %s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    //#define RKLogError(__FORMAT__, ...) TFLog((@"RKLogError - %s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

static NSString *const AccountIdentifier = @"4ad90c59aacf03cd3e58cc7c595ff348_NDI4OTcyMDExLTExLTIzIDAwOjI0OjI1LjcxNTMwOQ";

@implementation SLFTestFlight
- (void)beginTracking {
    [TestFlight performSelectorInBackground:@selector(takeOff:) withObject:AccountIdentifier];
}

- (void)endTracking {
    return;
}

- (void)pauseTracking {
    return;
}

- (void)resumeTracking {
    return;
}

- (void)tagEnvironmentVariables:(NSDictionary *)variables {
    [variables enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]])
            return;
        if (![obj respondsToSelector:@selector(description)])
            return;
        [TestFlight addCustomEnvironmentInformation:[obj description] forKey:key];
    }];
}

- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    [TestFlight passCheckpoint:event];
}

- (void)setOptIn:(BOOL)optedIn {
    return;
}

- (BOOL)isOptedIn {
    return YES;
}
@end
