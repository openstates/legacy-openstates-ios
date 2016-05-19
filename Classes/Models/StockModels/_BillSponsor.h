// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillSponsor.h instead.

#import <CoreData/CoreData.h>
#import "CommitteeMember.h"

@class SLFBill;


@interface BillSponsorID : NSManagedObjectID {}
@end

@interface _BillSponsor : CommitteeMember {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BillSponsorID*)objectID;





@property (nonatomic, strong) SLFBill* billInverse;

//- (BOOL)validateBillInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _BillSponsor (CoreDataGeneratedAccessors)

@end

@interface _BillSponsor (CoreDataGeneratedPrimitiveAccessors)



- (SLFBill*)primitiveBillInverse;
- (void)setPrimitiveBillInverse:(SLFBill*)value;


@end
