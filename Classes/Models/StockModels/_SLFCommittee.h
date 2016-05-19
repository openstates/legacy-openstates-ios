// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFCommittee.h instead.

#import <CoreData/CoreData.h>
#import <SLFRestKit/CoreData.h>

@class CommitteeMember;
@class GenericAsset;
@class SLFState;











@interface SLFCommitteeID : NSManagedObjectID {}
@end

@interface _SLFCommittee : RKSearchableManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFCommitteeID*)objectID;




@property (nonatomic, strong) NSString *chamber;


//- (BOOL)validateChamber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *committeeID;


//- (BOOL)validateCommitteeID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *committeeName;


//- (BOOL)validateCommitteeName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate *dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate *dateUpdated;


//- (BOOL)validateDateUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *parentID;


//- (BOOL)validateParentID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *subcommittee;


//- (BOOL)validateSubcommittee:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *votesmartID;


//- (BOOL)validateVotesmartID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* members;

- (NSMutableSet*)membersSet;




@property (nonatomic, strong) NSSet* sources;

- (NSMutableSet*)sourcesSet;




@property (nonatomic, strong) SLFState* stateObj;

//- (BOOL)validateStateObj:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFCommittee (CoreDataGeneratedAccessors)

- (void)addMembers:(NSSet*)value_;
- (void)removeMembers:(NSSet*)value_;
- (void)addMembersObject:(CommitteeMember*)value_;
- (void)removeMembersObject:(CommitteeMember*)value_;

- (void)addSources:(NSSet*)value_;
- (void)removeSources:(NSSet*)value_;
- (void)addSourcesObject:(GenericAsset*)value_;
- (void)removeSourcesObject:(GenericAsset*)value_;

@end

@interface _SLFCommittee (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChamber;
- (void)setPrimitiveChamber:(NSString*)value;




- (NSString*)primitiveCommitteeID;
- (void)setPrimitiveCommitteeID:(NSString*)value;




- (NSString*)primitiveCommitteeName;
- (void)setPrimitiveCommitteeName:(NSString*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateUpdated;
- (void)setPrimitiveDateUpdated:(NSDate*)value;




- (NSString*)primitiveParentID;
- (void)setPrimitiveParentID:(NSString*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveSubcommittee;
- (void)setPrimitiveSubcommittee:(NSString*)value;




- (NSString*)primitiveVotesmartID;
- (void)setPrimitiveVotesmartID:(NSString*)value;





- (NSMutableSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSources;
- (void)setPrimitiveSources:(NSMutableSet*)value;



- (SLFState*)primitiveStateObj;
- (void)setPrimitiveStateObj:(SLFState*)value;


@end
