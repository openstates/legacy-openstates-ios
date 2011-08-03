#import "SLFCommitteePosition.h"
#import "SLFLegislator.h"

@implementation SLFCommitteePosition

- (NSComparisonResult)compareCommitteeNames:(SLFCommitteePosition *)p
{    
    return [[[self committee] committeeName] compare: [[p committee] committeeName]];
}

- (NSComparisonResult)compareCommitteeMembers:(SLFCommitteePosition *)p
{    
    return [[[self legislator] fullNameLastFirst] compare: [[p legislator] fullNameLastFirst]];
}

@end
