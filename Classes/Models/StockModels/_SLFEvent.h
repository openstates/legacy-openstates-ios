// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFEvent.h instead.

#import <CoreData/CoreData.h>
#import <SLFRestKit/CoreData.h>

@class EventParticipant;
@class GenericAsset;
@class SLFState;













@interface SLFEventID : NSManagedObjectID {}
@end

@interface _SLFEvent : RKSearchableManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFEventID*)objectID;




@property (nonatomic, strong) NSDate *dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate *dateEnd;


//- (BOOL)validateDateEnd:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate *dateStart;


//- (BOOL)validateDateStart:(id*)value_ error:(NSError**)error_;


@property (nonatomic, copy) NSString *timezone;


@property (nonatomic, strong) NSDate *dateUpdated;


//- (BOOL)validateDateUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *eventDescription;


//- (BOOL)validateEventDescription:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *eventID;


//- (BOOL)validateEventID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *link;


//- (BOOL)validateLink:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *status;


//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *notes;


//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *ekEventIdentifier;


//- (BOOL)validateEkEventIdentifier:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *location;


//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *session;


//- (BOOL)validateSession:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString *type;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* participants;

- (NSMutableSet*)participantsSet;




@property (nonatomic, strong) NSSet* sources;

- (NSMutableSet*)sourcesSet;




@property (nonatomic, strong) SLFState* stateObj;

//- (BOOL)validateStateObj:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFEvent (CoreDataGeneratedAccessors)

- (void)addParticipants:(NSSet*)value_;
- (void)removeParticipants:(NSSet*)value_;
- (void)addParticipantsObject:(EventParticipant*)value_;
- (void)removeParticipantsObject:(EventParticipant*)value_;

- (void)addSources:(NSSet*)value_;
- (void)removeSources:(NSSet*)value_;
- (void)addSourcesObject:(GenericAsset*)value_;
- (void)removeSourcesObject:(GenericAsset*)value_;

@end

@interface _SLFEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateEnd;
- (void)setPrimitiveDateEnd:(NSDate*)value;




- (NSDate*)primitiveDateStart;
- (void)setPrimitiveDateStart:(NSDate*)value;




- (NSDate*)primitiveDateUpdated;
- (void)setPrimitiveDateUpdated:(NSDate*)value;




- (NSString*)primitiveEventDescription;
- (void)setPrimitiveEventDescription:(NSString*)value;




- (NSString*)primitiveEventID;
- (void)setPrimitiveEventID:(NSString*)value;




- (NSString*)primitiveLink;
- (void)setPrimitiveLink:(NSString*)value;




- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;




- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;




- (NSString*)primitiveEkEventIdentifier;
- (void)setPrimitiveEkEventIdentifier:(NSString*)value;




- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;




- (NSString*)primitiveSession;
- (void)setPrimitiveSession:(NSString*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;





- (NSMutableSet*)primitiveParticipants;
- (void)setPrimitiveParticipants:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSources;
- (void)setPrimitiveSources:(NSMutableSet*)value;



- (SLFState*)primitiveStateObj;
- (void)setPrimitiveStateObj:(SLFState*)value;


@end
