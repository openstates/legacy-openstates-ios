#import "SLFBill.h"
#import "SLFState.h"

@implementation SLFBill

- (void)setStateID:(NSString *)newID {
    [self willChangeValueForKey:@"stateID"];
    [self setPrimitiveStateID:newID];
    [self didChangeValueForKey:@"stateID"];
    
    if (!newID)
        return;
    
    SLFState *tempState = [SLFState findFirstByAttribute:@"abbreviation" withValue:newID];
    self.state = tempState;
}


@end
