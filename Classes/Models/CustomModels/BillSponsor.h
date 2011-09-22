#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "CommitteeMember.h"

@class SLFBill;
@interface BillSponsor : CommitteeMember
@property (nonatomic, retain) SLFBill *billInverse;
@end
