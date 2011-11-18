#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFBill.h"

@class SLFState;
@interface SLFBill : _SLFBill {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic,readonly) NSString *name;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
@property (nonatomic,readonly) NSArray *sortedActions;
@property (nonatomic,readonly) NSArray *sortedVotes;
@property (nonatomic,readonly) NSArray *sortedSponsors;
@property (nonatomic,readonly) NSArray *sortedSubjects;
@end
