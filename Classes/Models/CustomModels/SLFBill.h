#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFBill.h"

@class SLFState;
@interface SLFBill : _SLFBill {}
@property (nonatomic,readonly) SLFState *state;
@end
