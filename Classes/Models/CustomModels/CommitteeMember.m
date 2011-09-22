#import "SLFDataModels.h"

@implementation CommitteeMember
@dynamic legID;
@dynamic legislatorName;
@dynamic role;
@dynamic committeeInverse;

- (SLFLegislator *)foundLegislator {
    if (!self.legID)
        return nil;
    return [SLFLegislator findFirstByAttribute:@"legID" withValue:self.legID];
}
@end
