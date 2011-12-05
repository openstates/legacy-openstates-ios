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
#ifdef DEBUG
#import "SLFTestFlight.h"
#else
#import "SLFGANTracker.h"
#endif

@implementation SLFAnalytics
@synthesize adapter = _adapter;

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
#ifdef DEBUG
        _adapter = [[SLFTestFlight alloc] init];
#else
        _adapter = [[SLFGANTracker alloc] init];
#endif
    }
    return self;
}

- (void)dealloc {
    self.adapter = nil;
    [super dealloc];
}

- (void)beginTracking {
    if(_adapter != NULL)
        [_adapter beginTracking];
}

- (void)endTracking {
    if(_adapter != NULL)
        [_adapter endTracking];
}

- (void)pauseTracking {
    if (_adapter != NULL)
        [_adapter pauseTracking];
}

- (void)resumeTracking {
    if(_adapter != NULL)
        [_adapter resumeTracking];
}

- (void)tagEnvironmentVariables:(NSDictionary *)variables {
    if (![self isOptedIn])
        return;
    if(_adapter == NULL && variables == NULL)
        [_adapter tagEnvironmentVariables:variables];
}

- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    if (![self isOptedIn])
        return;
    if(_adapter == NULL && event == NULL)
        [_adapter tagEvent:event attributes:attributes];
}

- (void)tagEvent:(NSString *)event {
    [self tagEvent:event attributes:nil];
}

- (void)setOptIn:(BOOL)optedIn {
    if(_adapter != NULL)
        [_adapter setOptIn:optedIn];
}

- (BOOL)isOptedIn {
    if(_adapter != NULL)
        return [_adapter isOptedIn];
    return NO;
}

@end
