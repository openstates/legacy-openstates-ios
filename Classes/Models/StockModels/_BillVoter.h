// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillVoter.h instead.

#import <CoreData/CoreData.h>
#import "BillSponsor.h"

@class BillRecordVote;
@class BillRecordVote;
@class BillRecordVote;


@interface BillVoterID : NSManagedObjectID {}
@end

@interface _BillVoter : BillSponsor {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BillVoterID*)objectID;





@property (nonatomic, retain) BillRecordVote* noVoteInverse;

//- (BOOL)validateNoVoteInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) BillRecordVote* otherVoteInverse;

//- (BOOL)validateOtherVoteInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) BillRecordVote* yesVoteInverse;

//- (BOOL)validateYesVoteInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _BillVoter (CoreDataGeneratedAccessors)

@end

@interface _BillVoter (CoreDataGeneratedPrimitiveAccessors)



- (BillRecordVote*)primitiveNoVoteInverse;
- (void)setPrimitiveNoVoteInverse:(BillRecordVote*)value;



- (BillRecordVote*)primitiveOtherVoteInverse;
- (void)setPrimitiveOtherVoteInverse:(BillRecordVote*)value;



- (BillRecordVote*)primitiveYesVoteInverse;
- (void)setPrimitiveYesVoteInverse:(BillRecordVote*)value;


@end
