//
//  SLFAnalytics.m
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFAnalytics.h"

#define USE_TESTFLIGHT 0 // DEBUG
#define USE_GOOGLEANALYTICS 1
#define USE_LOCALYTICS 0

#if USE_TESTFLIGHT
#import "SLFTestFlight.h"
#endif

#if USE_GOOGLEANALYTICS
#import "SLFGANTracker.h"
#endif

#if USE_LOCALYTICS
#import "SLFLocalytics.h"
#endif

@interface SLFAnalytics()
@property (nonatomic,retain) NSMutableSet *adapters;
- (void)configureAdapters;
@end

@implementation SLFAnalytics
@synthesize adapters = _adapters;

+ (id)sharedAnalytics
{
    static dispatch_once_t pred;
    static SLFAnalytics *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureAdapters];
    }
    return self;
}

- (void)dealloc {
    self.adapters = nil;
    [super dealloc];
}

- (void)configureAdapters {
    self.adapters = [NSMutableSet set];
    
#if USE_TESTFLIGHT
    #warning TestFlight is enabled.  Turn off for AppStore and don't link against libTestFlight.a, if possible
    [self.adapters addObject:[[[SLFTestFlight alloc] init] autorelease]];
#endif
    
#if USE_GOOGLEANALYTICS
    [self.adapters addObject:[[[SLFGANTracker alloc] init] autorelease]];
#endif 
    
#if USE_LOCALYTICS
    [self.adapters addObject:[[[SLFLocalytics alloc] init] autorelease]];
#endif
}

- (void)beginTracking {
    if (IsEmpty(_adapters))
        [self configureAdapters];
    
    for (id<SLFAnalyticsAdapter> adapter in _adapters)
        [adapter beginTracking];
}

- (void)endTracking {
    for (id<SLFAnalyticsAdapter> adapter in _adapters)
        [adapter endTracking];
    self.adapters = nil;
}

- (void)pauseTracking {
    for (id<SLFAnalyticsAdapter> adapter in _adapters)
        [adapter pauseTracking];
}

- (void)resumeTracking {    
    for (id<SLFAnalyticsAdapter> adapter in _adapters)
        [adapter resumeTracking];
}

- (void)tagEnvironmentVariables:(NSDictionary *)variables {
    for (id<SLFAnalyticsAdapter> adapter in _adapters) {
        if (![adapter isOptedIn] || IsEmpty(variables))
            continue;
        [adapter tagEnvironmentVariables:variables];
    }
}

- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    for (id<SLFAnalyticsAdapter> adapter in _adapters) {
        if (![adapter isOptedIn] || IsEmpty(event))
            continue;
        [adapter tagEvent:event attributes:attributes];
    }
}

- (void)tagEvent:(NSString *)event {
    [self tagEvent:event attributes:nil];
}

- (void)setOptIn:(BOOL)optedIn {
    for (id<SLFAnalyticsAdapter> adapter in _adapters)
        [adapter setOptIn:optedIn];
}

- (BOOL)isOptedIn {
    for (id<SLFAnalyticsAdapter> adapter in _adapters)
        if (![adapter isOptedIn])
            return NO;
    return YES;
}

@end
