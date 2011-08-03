#import "SLFCommittee.h"
#import "SLFCommitteePosition.h"
#import "SLFState.h"

@implementation SLFCommittee

#pragma mark -
#pragma mark Relationship Mapping

- (void)setStateID:(NSString *)newID {
    [self willChangeValueForKey:@"stateID"];
    [self setPrimitiveStateID:newID];
    [self didChangeValueForKey:@"stateID"];
    
    if (!newID)
        return;
    
    SLFState *tempState = [SLFState findFirstByAttribute:@"abbreviation" withValue:newID];
    self.state = tempState;
}

#pragma mark -
#pragma mark Display Convenience

- (NSString *) committeeNameInitial {
	NSString * initial = [self.committeeName substringToIndex:1];
	return initial;
}

- (NSArray *)sortedMembers
{    
    NSArray *pos = [self.positions allObjects];
    if (pos) {
        NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"legislator.lastName" ascending:YES];
        [pos sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    }
    return pos;
}

@end
