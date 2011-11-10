// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFBill.h instead.

#import <CoreData/CoreData.h>


@class BillAction;
@class SLFWord;
@class BillSponsor;
@class SLFState;
@class SLFWord;
@class SLFWord;
@class BillRecordVote;





@class NSArray;

@class NSArray;


@class NSArray;

@interface SLFBillID : NSManagedObjectID {}
@end

@interface _SLFBill : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFBillID*)objectID;




@property (nonatomic, retain) NSString *billID;


//- (BOOL)validateBillID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateUpdated;


//- (BOOL)validateDateUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *documents;


//- (BOOL)validateDocuments:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *session;


//- (BOOL)validateSession:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *sources;


//- (BOOL)validateSources:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *versions;


//- (BOOL)validateVersions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* actions;

- (NSMutableSet*)actionsSet;




@property (nonatomic, retain) NSSet* alternateTitles;

- (NSMutableSet*)alternateTitlesSet;




@property (nonatomic, retain) NSSet* sponsors;

- (NSMutableSet*)sponsorsSet;




@property (nonatomic, retain) SLFState* stateObj;

//- (BOOL)validateStateObj:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* subjects;

- (NSMutableSet*)subjectsSet;




@property (nonatomic, retain) NSSet* type;

- (NSMutableSet*)typeSet;




@property (nonatomic, retain) NSSet* votes;

- (NSMutableSet*)votesSet;




@end

@interface _SLFBill (CoreDataGeneratedAccessors)

- (void)addActions:(NSSet*)value_;
- (void)removeActions:(NSSet*)value_;
- (void)addActionsObject:(BillAction*)value_;
- (void)removeActionsObject:(BillAction*)value_;

- (void)addAlternateTitles:(NSSet*)value_;
- (void)removeAlternateTitles:(NSSet*)value_;
- (void)addAlternateTitlesObject:(SLFWord*)value_;
- (void)removeAlternateTitlesObject:(SLFWord*)value_;

- (void)addSponsors:(NSSet*)value_;
- (void)removeSponsors:(NSSet*)value_;
- (void)addSponsorsObject:(BillSponsor*)value_;
- (void)removeSponsorsObject:(BillSponsor*)value_;

- (void)addSubjects:(NSSet*)value_;
- (void)removeSubjects:(NSSet*)value_;
- (void)addSubjectsObject:(SLFWord*)value_;
- (void)removeSubjectsObject:(SLFWord*)value_;

- (void)addType:(NSSet*)value_;
- (void)removeType:(NSSet*)value_;
- (void)addTypeObject:(SLFWord*)value_;
- (void)removeTypeObject:(SLFWord*)value_;

- (void)addVotes:(NSSet*)value_;
- (void)removeVotes:(NSSet*)value_;
- (void)addVotesObject:(BillRecordVote*)value_;
- (void)removeVotesObject:(BillRecordVote*)value_;

@end

@interface _SLFBill (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBillID;
- (void)setPrimitiveBillID:(NSString*)value;




- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateUpdated;
- (void)setPrimitiveDateUpdated:(NSDate*)value;




- (NSArray*)primitiveDocuments;
- (void)setPrimitiveDocuments:(NSArray*)value;




- (NSString*)primitiveSession;
- (void)setPrimitiveSession:(NSString*)value;




- (NSArray*)primitiveSources;
- (void)setPrimitiveSources:(NSArray*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSArray*)primitiveVersions;
- (void)setPrimitiveVersions:(NSArray*)value;





- (NSMutableSet*)primitiveActions;
- (void)setPrimitiveActions:(NSMutableSet*)value;



- (NSMutableSet*)primitiveAlternateTitles;
- (void)setPrimitiveAlternateTitles:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSponsors;
- (void)setPrimitiveSponsors:(NSMutableSet*)value;



- (SLFState*)primitiveStateObj;
- (void)setPrimitiveStateObj:(SLFState*)value;



- (NSMutableSet*)primitiveSubjects;
- (void)setPrimitiveSubjects:(NSMutableSet*)value;



- (NSMutableSet*)primitiveType;
- (void)setPrimitiveType:(NSMutableSet*)value;



- (NSMutableSet*)primitiveVotes;
- (void)setPrimitiveVotes:(NSMutableSet*)value;


@end
