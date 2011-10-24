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

- (NSString *) initial {
	return [self.committeeName substringToIndex:1];
}

- (NSArray *)sortedMembers
{    
    if (!self.members)
        return nil;
    return [self.members sortedArrayUsingDescriptors:[CommitteeMember sortDescriptors]];
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [NSSortDescriptor sortDescriptorWithKey:@"committeeName" ascending:YES];
    NSSortDescriptor *chamberDesc = [NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, chamberDesc, nil];
}
@end
