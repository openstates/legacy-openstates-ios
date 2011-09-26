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

NSString * const SLFSelectedStateDidChangeNotification = @"SLFSelectedStateDidChange";

/* Convenience functions for pulling user's state settings  from NSUserDefaults efficiently */

NSString* SLFSelectedStateID(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedState"];
}

SLFState* SLFSelectedState(void) {
    if (IsEmpty(SLFSelectedStateID()))
        return nil;
    return [SLFState findFirstByAttribute:@"stateID" withValue:SLFSelectedStateID()]; 
}

void SLFSaveSelectedState(SLFState *state) {
    NSCParameterAssert(state != NULL && state.stateID != NULL);
    SLFSaveSelectedStateID(state.stateID);
}

void SLFSaveSelectedStateID(NSString *stateID) {
    NSCParameterAssert(stateID != NULL);
    [[NSUserDefaults standardUserDefaults] setObject:stateID forKey:@"selectedState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
