//
//  SLFGANTracker.m
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFGANTracker.h"
#include "GANTracker.h"

static NSString *const AccountIdentifier = @"UA-22821126-11";
static const NSInteger kDefaultDispatchPeriod = 60;
static const BOOL kDefaultDebugEnabled = NO;
static const BOOL kDefaultAnalyticsDisabled = NO;
static const BOOL kDefaultAnonymizeIpEnabled = YES;
static const NSInteger kDefaultSampleRate = 100;

@interface SLFGANTracker()
@end


@implementation SLFGANTracker

- (void)beginTracking {
    [[GANTracker sharedTracker] startTrackerWithAccountID:AccountIdentifier dispatchPeriod:kDefaultDispatchPeriod delegate:nil];
}

- (void)endTracking {
   [[GANTracker sharedTracker] stopTracker];
}

- (void)pauseTracking {
    [[GANTracker sharedTracker] dispatch];
}

- (void)resumeTracking {
    return;
}

- (void)tagEnvironmentVariables:(NSDictionary *)variables {
    NSInteger index = 0;
    for (NSString *key in [variables allKeys]) {
        id value = [variables valueForKey:key];
        if (!value || [[NSNull null] isEqual:value])
            continue;
        NSError *error = nil;
        [[GANTracker sharedTracker] setCustomVariableAtIndex:index name:key value:[value description] withError:&error];
        index ++;
    }
}

- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    NSError *error = nil;
    NSString *activityPath = nil;
    if (event && [event hasPrefix:@"slfos://"]) {
        //activityPath = [event stringByReplacingOccurrencesOfString:@"slfos://" withString:@"http;//ios.openstates.org/"];
        activityPath = [event stringByReplacingOccurrencesOfString:@"slfos://" withString:@"/"];
        event = nil;
    }
    if (activityPath) {
        if (![[GANTracker sharedTracker] trackPageview:activityPath withError:&error])
            NSLog(@"Error sending page tracking (%@) to Google Analytics: %@", activityPath, error);
    }
    if (event) {
        NSString *category = @"";
        if (attributes && [attributes valueForKey:@"category"])
            category = [attributes valueForKey:@"category"];
        if (![[GANTracker sharedTracker] trackEvent:category action:event label:nil value:0 withError:&error])
            NSLog(@"Error sending event tracking (%@) to Google Analytics: %@", event, error);
    }
    return;
}

- (void)setOptIn:(BOOL)optedIn {
    return;
}

- (BOOL)isOptedIn {
    return !(IsEmpty(AccountIdentifier));
}
@end
