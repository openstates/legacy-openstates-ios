#import "SLFState.h"

@implementation SLFState

- (BOOL)isFeatureEnabled:(NSString *)feature {
    if ( feature && [feature length] && 
        (self.featureFlags && [self.featureFlags containsObject:feature]) ) {
        return YES;
    }
    return NO;
}


- (NSString *)displayNameForSession:(NSString *)aSession {
    NSString *display = aSession;
    
    if ( [aSession length] == 0  || !self.sessionDetails )
        return display;
    
    NSDictionary * sessionDetail = [self.sessionDetails objectForKey:aSession];
    if (sessionDetail) {
        
        NSString * tempName = [sessionDetail objectForKey:@"display_name"];
        if (tempName && [tempName length]) {
            display = tempName;
        }
    }
    return display;
}

@end
