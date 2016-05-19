#import "_BillAction.h"

@class RKManagedObjectMapping;
@interface BillAction : _BillAction {}
@property (weak, nonatomic,readonly) NSString *title;
@property (weak, nonatomic,readonly) NSString *subtitle;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
