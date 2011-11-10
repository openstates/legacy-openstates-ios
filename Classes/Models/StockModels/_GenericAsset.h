// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GenericAsset.h instead.

#import <CoreData/CoreData.h>


@class SLFBill;
@class SLFBill;
@class SLFBill;
@class SLFCommittee;
@class SLFEvent;
@class SLFLegislator;
@class BillRecordVote;




@interface GenericAssetID : NSManagedObjectID {}
@end

@interface _GenericAsset : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GenericAssetID*)objectID;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *url;


//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFBill* billDocumentsInverse;

//- (BOOL)validateBillDocumentsInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFBill* billSourcesInverse;

//- (BOOL)validateBillSourcesInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFBill* billVersionsInverse;

//- (BOOL)validateBillVersionsInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFCommittee* committeeInverse;

//- (BOOL)validateCommitteeInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFEvent* eventInverse;

//- (BOOL)validateEventInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFLegislator* legislatorInverse;

//- (BOOL)validateLegislatorInverse:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) BillRecordVote* voteInverse;

//- (BOOL)validateVoteInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _GenericAsset (CoreDataGeneratedAccessors)

@end

@interface _GenericAsset (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (SLFBill*)primitiveBillDocumentsInverse;
- (void)setPrimitiveBillDocumentsInverse:(SLFBill*)value;



- (SLFBill*)primitiveBillSourcesInverse;
- (void)setPrimitiveBillSourcesInverse:(SLFBill*)value;



- (SLFBill*)primitiveBillVersionsInverse;
- (void)setPrimitiveBillVersionsInverse:(SLFBill*)value;



- (SLFCommittee*)primitiveCommitteeInverse;
- (void)setPrimitiveCommitteeInverse:(SLFCommittee*)value;



- (SLFEvent*)primitiveEventInverse;
- (void)setPrimitiveEventInverse:(SLFEvent*)value;



- (SLFLegislator*)primitiveLegislatorInverse;
- (void)setPrimitiveLegislatorInverse:(SLFLegislator*)value;



- (BillRecordVote*)primitiveVoteInverse;
- (void)setPrimitiveVoteInverse:(BillRecordVote*)value;


@end
