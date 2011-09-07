#import "SLFBill.h"
#import "SLFState.h"

@implementation SLFBill

// This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

- (NSString *)watchID {
    return [NSString stringWithFormat:@"%@:%@", self.session, self.billID];
}

@end
