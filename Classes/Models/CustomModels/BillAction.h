#import "_BillAction.h"

@class RKManagedObjectMapping;
@interface BillAction : _BillAction {}
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) NSString *subtitle;
+ (RKManagedObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end
