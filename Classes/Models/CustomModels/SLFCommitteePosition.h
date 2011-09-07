#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFCommitteePosition.h"

@interface SLFCommitteePosition : _SLFCommitteePosition {}

- (NSComparisonResult)compareCommitteeNames:(SLFCommitteePosition *)p;
- (NSComparisonResult)compareCommitteeMembers:(SLFCommitteePosition *)p;

@end

    // Committe Position Roles
enum kPositions {
    POS_MEMBER = 0,
    POS_VICE,
    POS_CHAIR
};

