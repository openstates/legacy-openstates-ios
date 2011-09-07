#import "SLFCommittee.h"
#import "SLFCommitteePosition.h"
#import "SLFState.h"

@implementation SLFCommittee

#pragma mark -
#pragma mark Relationship Mapping

// This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

#pragma mark -
#pragma mark Display Convenience

- (NSString *) committeeNameInitial {
	NSString * initial = [self.committeeName substringToIndex:1];
	return initial;
}

- (NSArray *)sortedMembers
{    
    if (self.positions) {
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"legislator.fullNameLastFirst" ascending:YES];
        return [self.positions sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    }
    return nil;
}

@end
