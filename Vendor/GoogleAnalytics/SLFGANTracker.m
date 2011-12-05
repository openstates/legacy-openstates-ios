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

static NSString *const AccountIdentifier = @"UA-00000000-1";
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
    NSString *category = @"";
    if (attributes && [attributes valueForKey:@"category"])
        category = [attributes valueForKey:@"category"];
    NSString *activityPath = nil;
    if (attributes && [attributes valueForKey:@"ActivityPath"])
        activityPath = [attributes valueForKey:@"ActivityPath"];
    if (event && [event hasPrefix:@"slfos://"]) {
        activityPath = event;
        event = nil;
    }
    if (activityPath)
        [[GANTracker sharedTracker] trackPageview:activityPath withError:&error];
    if (event)
        [[GANTracker sharedTracker] trackEvent:category action:event label:nil value:0 withError:&error];
    return;
}

- (void)setOptIn:(BOOL)optedIn {
    return;
}

- (BOOL)isOptedIn {
    return !(IsEmpty(AccountIdentifier));
}
@end
