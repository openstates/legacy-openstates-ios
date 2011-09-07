#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFCommittee.h"

@class SLFState;
@interface SLFCommittee : _SLFCommittee {}
@property (nonatomic,readonly) SLFState *state;
- (NSArray *) sortedMembers;
@end
