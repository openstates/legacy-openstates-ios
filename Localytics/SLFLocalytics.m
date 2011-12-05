//
//  SLFLocalytics.m
//  Created by Greg Combs on 12/5/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFLocalytics.h"
#import "LocalyticsSession.h"

static NSString *const AccountIdentifier = @"af38bceffbf0e727cb5fb28-a26bb050-1f21-11e1-95d9-007bc6310ec9";

@implementation SLFLocalytics

- (void)beginTracking {
     [[LocalyticsSession sharedLocalyticsSession] startSession:AccountIdentifier];
}

- (void)endTracking {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)pauseTracking {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)resumeTracking {
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)tagEnvironmentVariables:(NSDictionary *)variables {
    return;
}

- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:event attributes:attributes];
}

- (void)setOptIn:(BOOL)optedIn {
    [[LocalyticsSession sharedLocalyticsSession] setOptIn:optedIn];
}

- (BOOL)isOptedIn {
    return [[LocalyticsSession sharedLocalyticsSession] isOptedIn];
}
@end
