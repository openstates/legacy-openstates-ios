#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class SLFLegislator;
@interface CommitteeRole : NSManagedObject
@property (nonatomic, retain) NSString * committeeID;
@property (nonatomic, retain) NSString * committeeName;
@property (nonatomic, retain) NSString * chamber;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) SLFLegislator *legislatorInverse;
@property (nonatomic, readonly) SLFCommittee *foundCommittee;
@end
