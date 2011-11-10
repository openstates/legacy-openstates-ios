// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BillRecordVote.h instead.

#import <CoreData/CoreData.h>


@class SLFBill;
@class BillVoter;
@class BillVoter;
@class BillVoter;











@class NSArray;





@interface BillRecordVoteID : NSManagedObjectID {}
@end

@interface _BillRecordVote : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BillRecordVoteID*)objectID;




@property (nonatomic, retain) NSString *billChamber;


//- (BOOL)validateBillChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *date;


//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *method;


//- (BOOL)validateMethod:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *motion;


//- (BOOL)validateMotion:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *noCount;


@property short noCountValue;
- (short)noCountValue;
- (void)setNoCountValue:(short)value_;

//- (BOOL)validateNoCount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *otherCount;


@property short otherCountValue;
- (short)otherCountValue;
- (void)setOtherCountValue:(short)value_;

//- (BOOL)validateOtherCount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *passed;


@property BOOL passedValue;
- (BOOL)passedValue;
- (void)setPassedValue:(BOOL)value_;

//- (BOOL)validatePassed:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *record;


//- (BOOL)validateRecord:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *session;


//- (BOOL)validateSession:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *sources;


//- (BOOL)validateSources:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *type;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *voteID;


//- (BOOL)validateVoteID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *yesCount;


@property short yesCountValue;
- (short)yesCountValue;
- (void)setYesCountValue:(short)value_;

//- (BOOL)validateYesCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFBill* bill;

//- (BOOL)validateBill:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* noVotes;

- (NSMutableSet*)noVotesSet;




@property (nonatomic, retain) NSSet* otherVotes;

- (NSMutableSet*)otherVotesSet;




@property (nonatomic, retain) NSSet* yesVotes;

- (NSMutableSet*)yesVotesSet;




@end

@interface _BillRecordVote (CoreDataGeneratedAccessors)

- (void)addNoVotes:(NSSet*)value_;
- (void)removeNoVotes:(NSSet*)value_;
- (void)addNoVotesObject:(BillVoter*)value_;
- (void)removeNoVotesObject:(BillVoter*)value_;

- (void)addOtherVotes:(NSSet*)value_;
- (void)removeOtherVotes:(NSSet*)value_;
- (void)addOtherVotesObject:(BillVoter*)value_;
- (void)removeOtherVotesObject:(BillVoter*)value_;

- (void)addYesVotes:(NSSet*)value_;
- (void)removeYesVotes:(NSSet*)value_;
- (void)addYesVotesObject:(BillVoter*)value_;
- (void)removeYesVotesObject:(BillVoter*)value_;

@end

@interface _BillRecordVote (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBillChamber;
- (void)setPrimitiveBillChamber:(NSString*)value;




- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSString*)primitiveMethod;
- (void)setPrimitiveMethod:(NSString*)value;




- (NSString*)primitiveMotion;
- (void)setPrimitiveMotion:(NSString*)value;




- (NSNumber*)primitiveNoCount;
- (void)setPrimitiveNoCount:(NSNumber*)value;

- (short)primitiveNoCountValue;
- (void)setPrimitiveNoCountValue:(short)value_;




- (NSNumber*)primitiveOtherCount;
- (void)setPrimitiveOtherCount:(NSNumber*)value;

- (short)primitiveOtherCountValue;
- (void)setPrimitiveOtherCountValue:(short)value_;




- (NSNumber*)primitivePassed;
- (void)setPrimitivePassed:(NSNumber*)value;

- (BOOL)primitivePassedValue;
- (void)setPrimitivePassedValue:(BOOL)value_;




- (NSString*)primitiveRecord;
- (void)setPrimitiveRecord:(NSString*)value;




- (NSString*)primitiveSession;
- (void)setPrimitiveSession:(NSString*)value;




- (NSArray*)primitiveSources;
- (void)setPrimitiveSources:(NSArray*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveVoteID;
- (void)setPrimitiveVoteID:(NSString*)value;




- (NSNumber*)primitiveYesCount;
- (void)setPrimitiveYesCount:(NSNumber*)value;

- (short)primitiveYesCountValue;
- (void)setPrimitiveYesCountValue:(short)value_;





- (SLFBill*)primitiveBill;
- (void)setPrimitiveBill:(SLFBill*)value;



- (NSMutableSet*)primitiveNoVotes;
- (void)setPrimitiveNoVotes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOtherVotes;
- (void)setPrimitiveOtherVotes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveYesVotes;
- (void)setPrimitiveYesVotes:(NSMutableSet*)value;


@end
