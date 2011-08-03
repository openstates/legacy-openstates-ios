#import "SLFState.h"

@implementation SLFState

- (NSString *)nameForChamber:(NSInteger)chamber {
	    
	// prepare to make some assumptions
	if (chamber != HOUSE && chamber != SENATE)
        return nil;
    
	NSString *aName = self.upperChamberName;        
    if (chamber == HOUSE)
        aName = self.lowerChamberName;;
    
    if (aName && [aName length]) {
        NSArray *words = [aName componentsSeparatedByString:@" "];
        if ([words count] > 1 && [[words objectAtIndex:0] length] > 4) { // just to make sure we have a decent, single name
            aName = [words objectAtIndex:0];
        }
    }
    
	return aName;
}


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
