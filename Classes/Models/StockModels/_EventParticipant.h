// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventParticipant.h instead.

#import <CoreData/CoreData.h>
#import "GenericNamedItem.h"

@class SLFEvent;


@interface EventParticipantID : NSManagedObjectID {}
@end

@interface _EventParticipant : GenericNamedItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EventParticipantID*)objectID;





@property (nonatomic, retain) SLFEvent* eventInverse;

//- (BOOL)validateEventInverse:(id*)value_ error:(NSError**)error_;




@end

@interface _EventParticipant (CoreDataGeneratedAccessors)

@end

@interface _EventParticipant (CoreDataGeneratedPrimitiveAccessors)



- (SLFEvent*)primitiveEventInverse;
- (void)setPrimitiveEventInverse:(SLFEvent*)value;


@end
