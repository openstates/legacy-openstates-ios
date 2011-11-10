// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommitteeMember.h instead.

#import <CoreData/CoreData.h>
#import "GenericNamedItem.h"

@class SLFCommittee;



@interface CommitteeMemberID : NSManagedObjectID {}
@end

@interface _CommitteeMember : GenericNamedItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommitteeMemberID*)objectID;




@property (nonatomic, retain) NSString *legID;


//- (BOOL)validateLegID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFCommittee* committeeInverse;

//- (BOOL)validateCommitteeInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _CommitteeMember (CoreDataGeneratedAccessors)

@end

@interface _CommitteeMember (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveLegID;
- (void)setPrimitiveLegID:(NSString*)value;





- (SLFCommittee*)primitiveCommitteeInverse;
- (void)setPrimitiveCommitteeInverse:(SLFCommittee*)value;


@end
