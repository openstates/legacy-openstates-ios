#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class SLFCommittee;
@class SLFLegislator;
@interface CommitteeMember : NSManagedObject
@property (nonatomic, retain) NSString * legID;
@property (nonatomic, retain) NSString * legislatorName;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) SLFCommittee *committeeInverse;
@property (nonatomic, readonly) SLFLegislator *foundLegislator;
+ (NSArray *)sortDescriptors;
@end
