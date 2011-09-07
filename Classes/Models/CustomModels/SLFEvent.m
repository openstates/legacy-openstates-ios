#import "SLFEvent.h"
#import "SLFState.h"

@implementation SLFEvent

// This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

@end
