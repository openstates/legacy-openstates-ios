// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFCommitteePosition.m instead.

#import "_SLFCommitteePosition.h"

@implementation SLFCommitteePositionID
@end

@implementation _SLFCommitteePosition

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFCommitteePosition" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFCommitteePosition";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFCommitteePosition" inManagedObjectContext:moc_];
}

- (SLFCommitteePositionID*)objectID {
	return (SLFCommitteePositionID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic committeeID;






@dynamic committeeName;






@dynamic legID;






@dynamic legislatorName;






@dynamic posID;






@dynamic positionType;






@dynamic committee;

	

@dynamic legislator;

	





@end
