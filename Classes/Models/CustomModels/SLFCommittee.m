#import "SLFDataModels.h"

@implementation SLFCommittee

#pragma mark -
#pragma mark Relationship Mapping

// This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

#pragma mark -
#pragma mark Display Convenience

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.state];
}

- (NSString *)chamberShortName {
    return self.chamberObj.shortName;
}

- (NSString *) committeeNameInitial {
	NSString * initial = [self.committeeName substringToIndex:1];
	return initial;
}

- (NSArray *)sortedMembers
{    
    if (self.members) {
        NSSortDescriptor *role = [NSSortDescriptor sortDescriptorWithKey:@"role" ascending:YES];
        NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"foundLegislator.lastName" ascending:YES];
        return [self.members sortedArrayUsingDescriptors:[NSArray arrayWithObjects:role, name, nil]];
    }
    return nil;
}

@end
