// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFBill.h instead.

#import <CoreData/CoreData.h>
#import <RestKit/CoreData/CoreData.h>

@class BillAction;
@class GenericWord;
@class GenericAsset;
@class GenericAsset;
@class BillSponsor;
@class SLFState;
@class GenericWord;
@class GenericWord;
@class GenericAsset;
@class BillRecordVote;









@interface SLFBillID : NSManagedObjectID {}
@end

//@interface _SLFBill : NSManagedObject {}
@interface _SLFBill : RKSearchableManagedObject {}
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




@property (nonatomic, retain) NSString *session;


//- (BOOL)validateSession:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* actions;

- (NSMutableSet*)actionsSet;




@property (nonatomic, retain) NSSet* alternateTitles;

- (NSMutableSet*)alternateTitlesSet;




@property (nonatomic, retain) NSSet* documents;

- (NSMutableSet*)documentsSet;




@property (nonatomic, retain) NSSet* sources;

- (NSMutableSet*)sourcesSet;




@property (nonatomic, retain) NSSet* sponsors;

- (NSMutableSet*)sponsorsSet;




@property (nonatomic, retain) SLFState* stateObj;

//- (BOOL)validateStateObj:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* subjects;

- (NSMutableSet*)subjectsSet;




@property (nonatomic, retain) NSSet* types;

- (NSMutableSet*)typesSet;




@property (nonatomic, retain) NSSet* versions;

- (NSMutableSet*)versionsSet;




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
- (void)addAlternateTitlesObject:(GenericWord*)value_;
- (void)removeAlternateTitlesObject:(GenericWord*)value_;

- (void)addDocuments:(NSSet*)value_;
- (void)removeDocuments:(NSSet*)value_;
- (void)addDocumentsObject:(GenericAsset*)value_;
- (void)removeDocumentsObject:(GenericAsset*)value_;

- (void)addSources:(NSSet*)value_;
- (void)removeSources:(NSSet*)value_;
- (void)addSourcesObject:(GenericAsset*)value_;
- (void)removeSourcesObject:(GenericAsset*)value_;

- (void)addSponsors:(NSSet*)value_;
- (void)removeSponsors:(NSSet*)value_;
- (void)addSponsorsObject:(BillSponsor*)value_;
- (void)removeSponsorsObject:(BillSponsor*)value_;

- (void)addSubjects:(NSSet*)value_;
- (void)removeSubjects:(NSSet*)value_;
- (void)addSubjectsObject:(GenericWord*)value_;
- (void)removeSubjectsObject:(GenericWord*)value_;

- (void)addTypes:(NSSet*)value_;
- (void)removeTypes:(NSSet*)value_;
- (void)addTypesObject:(GenericWord*)value_;
- (void)removeTypesObject:(GenericWord*)value_;

- (void)addVersions:(NSSet*)value_;
- (void)removeVersions:(NSSet*)value_;
- (void)addVersionsObject:(GenericAsset*)value_;
- (void)removeVersionsObject:(GenericAsset*)value_;

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




- (NSString*)primitiveSession;
- (void)setPrimitiveSession:(NSString*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveActions;
- (void)setPrimitiveActions:(NSMutableSet*)value;



- (NSMutableSet*)primitiveAlternateTitles;
- (void)setPrimitiveAlternateTitles:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDocuments;
- (void)setPrimitiveDocuments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSources;
- (void)setPrimitiveSources:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSponsors;
- (void)setPrimitiveSponsors:(NSMutableSet*)value;



- (SLFState*)primitiveStateObj;
- (void)setPrimitiveStateObj:(SLFState*)value;



- (NSMutableSet*)primitiveSubjects;
- (void)setPrimitiveSubjects:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTypes;
- (void)setPrimitiveTypes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveVersions;
- (void)setPrimitiveVersions:(NSMutableSet*)value;



- (NSMutableSet*)primitiveVotes;
- (void)setPrimitiveVotes:(NSMutableSet*)value;


@end
