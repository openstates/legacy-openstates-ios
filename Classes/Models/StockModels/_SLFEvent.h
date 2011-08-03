// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFEvent.h instead.

#import <CoreData/CoreData.h>


@class SLFState;









@class NSArray;

@class NSArray;



@interface SLFEventID : NSManagedObjectID {}
@end

@interface _SLFEvent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SLFEventID*)objectID;




@property (nonatomic, retain) NSDate *dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateEnd;


//- (BOOL)validateDateEnd:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateStart;


//- (BOOL)validateDateStart:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *dateUpdated;


//- (BOOL)validateDateUpdated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *eventDescription;


//- (BOOL)validateEventDescription:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *eventID;


//- (BOOL)validateEventID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *link;


//- (BOOL)validateLink:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *location;


//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *participants;


//- (BOOL)validateParticipants:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *session;


//- (BOOL)validateSession:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSArray *sources;


//- (BOOL)validateSources:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *stateID;


//- (BOOL)validateStateID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *type;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SLFState* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@end

@interface _SLFEvent (CoreDataGeneratedAccessors)

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




- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;




- (NSArray*)primitiveParticipants;
- (void)setPrimitiveParticipants:(NSArray*)value;




- (NSString*)primitiveSession;
- (void)setPrimitiveSession:(NSString*)value;




- (NSArray*)primitiveSources;
- (void)setPrimitiveSources:(NSArray*)value;




- (NSString*)primitiveStateID;
- (void)setPrimitiveStateID:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;





- (SLFState*)primitiveState;
- (void)setPrimitiveState:(SLFState*)value;


@end
