// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFEvent.m instead.

#import "_SLFEvent.h"

@implementation SLFEventID
@end

@implementation _SLFEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFEvent" inManagedObjectContext:moc_];
}

- (SLFEventID*)objectID {
	return (SLFEventID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic dateCreated;






@dynamic dateEnd;






@dynamic dateStart;






@dynamic dateUpdated;






@dynamic eventDescription;






@dynamic eventID;






@dynamic link;






@dynamic status;






@dynamic notes;






@dynamic ekEventIdentifier;






@dynamic location;






@dynamic session;






@dynamic stateID;






@dynamic type;






@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
	[self didAccessValueForKey:@"participants"];
	return result;
}
	

@dynamic sources;

	
- (NSMutableSet*)sourcesSet {
	[self willAccessValueForKey:@"sources"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sources"];
	[self didAccessValueForKey:@"sources"];
	return result;
}
	

@dynamic stateObj;

	





@end
