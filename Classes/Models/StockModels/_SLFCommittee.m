// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFCommittee.m instead.

#import "_SLFCommittee.h"

@implementation SLFCommitteeID
@end

@implementation _SLFCommittee

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFCommittee" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFCommittee";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFCommittee" inManagedObjectContext:moc_];
}

- (SLFCommitteeID*)objectID {
	return (SLFCommitteeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic chamber;






@dynamic committeeID;






@dynamic committeeName;






@dynamic dateCreated;






@dynamic dateUpdated;






@dynamic members;

- (NSMutableSet*)membersSet {
	[self willAccessValueForKey:@"members"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"members"];
	[self didAccessValueForKey:@"members"];
	return result;
}





@dynamic parentID;






@dynamic sources;






@dynamic stateID;






@dynamic subcommittee;






@dynamic votesmartID;






@dynamic stateObj;

	





@end
