// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFCommitteePosition.h instead.

#import <CoreData/CoreData.h>


@class SLFCommittee;
@class SLFLegislator;








@interface SLFCommitteePositionID : NSManagedObjectID {}
@end

@interface _SLFCommitteePosition : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFCommitteePositionID*)objectID;




@property (nonatomic, retain) NSString *committeeID;


//- (BOOL)validateCommitteeID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *committeeName;


//- (BOOL)validateCommitteeName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *legID;


//- (BOOL)validateLegID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *legislatorName;


//- (BOOL)validateLegislatorName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *posID;


//- (BOOL)validatePosID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *positionType;


//- (BOOL)validatePositionType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFCommittee* committee;

//- (BOOL)validateCommittee:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SLFLegislator* legislator;

//- (BOOL)validateLegislator:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFCommitteePosition (CoreDataGeneratedAccessors)

@end

@interface _SLFCommitteePosition (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCommitteeID;
- (void)setPrimitiveCommitteeID:(NSString*)value;




- (NSString*)primitiveCommitteeName;
- (void)setPrimitiveCommitteeName:(NSString*)value;




- (NSString*)primitiveLegID;
- (void)setPrimitiveLegID:(NSString*)value;




- (NSString*)primitiveLegislatorName;
- (void)setPrimitiveLegislatorName:(NSString*)value;




- (NSString*)primitivePosID;
- (void)setPrimitivePosID:(NSString*)value;




- (NSString*)primitivePositionType;
- (void)setPrimitivePositionType:(NSString*)value;





- (SLFCommittee*)primitiveCommittee;
- (void)setPrimitiveCommittee:(SLFCommittee*)value;



- (SLFLegislator*)primitiveLegislator;
- (void)setPrimitiveLegislator:(SLFLegislator*)value;


@end
