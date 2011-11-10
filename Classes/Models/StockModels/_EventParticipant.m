// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EventParticipant.m instead.

#import "_EventParticipant.h"

@implementation EventParticipantID
@end

@implementation _EventParticipant

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"EventParticipant" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"EventParticipant";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"EventParticipant" inManagedObjectContext:moc_];
}

- (EventParticipantID*)objectID {
	return (EventParticipantID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic eventInverse;

	





@end
