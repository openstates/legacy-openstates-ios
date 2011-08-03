// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFBill.h instead.

#import <CoreData/CoreData.h>


@class SLFState;

@class NSArray;




@class NSArray;

@class NSArray;
@class NSArray;

@class NSArray;

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




@property (nonatomic, retain) NSArray *actions;


//- (BOOL)validateActions:(id*)value_ error:(NSError**)error_;




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




@property (nonatomic, retain) NSArray *sponsors;


//- (BOOL)validateSponsors:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *subjects;


//- (BOOL)validateSubjects:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *type;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *versions;


//- (BOOL)validateVersions:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *votes;


//- (BOOL)validateVotes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFState* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFBill (CoreDataGeneratedAccessors)

@end

@interface _SLFBill (CoreDataGeneratedPrimitiveAccessors)


- (NSArray*)primitiveActions;
- (void)setPrimitiveActions:(NSArray*)value;




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




- (NSArray*)primitiveSponsors;
- (void)setPrimitiveSponsors:(NSArray*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSArray*)primitiveSubjects;
- (void)setPrimitiveSubjects:(NSArray*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSArray*)primitiveType;
- (void)setPrimitiveType:(NSArray*)value;




- (NSArray*)primitiveVersions;
- (void)setPrimitiveVersions:(NSArray*)value;




- (NSArray*)primitiveVotes;
- (void)setPrimitiveVotes:(NSArray*)value;





- (SLFState*)primitiveState;
- (void)setPrimitiveState:(SLFState*)value;


@end
