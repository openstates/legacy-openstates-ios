// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFLegislator.m instead.

#import "_SLFLegislator.h"

@implementation SLFLegislatorID
@end

@implementation _SLFLegislator

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFLegislator" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFLegislator";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFLegislator" inManagedObjectContext:moc_];
}

- (SLFLegislatorID*)objectID {
	return (SLFLegislatorID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"active"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic active;



- (BOOL)activeValue {
	NSNumber *result = [self active];
	return [result boolValue];
}

- (void)setActiveValue:(BOOL)value_ {
	[self setActive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveValue {
	NSNumber *result = [self primitiveActive];
	return [result boolValue];
}

- (void)setPrimitiveActiveValue:(BOOL)value_ {
	[self setPrimitiveActive:[NSNumber numberWithBool:value_]];
}





@dynamic chamber;






@dynamic country;






@dynamic dateCreated;






@dynamic dateUpdated;






@dynamic district;






@dynamic firstName;






@dynamic fullName;






@dynamic lastName;






@dynamic legID;






@dynamic level;






@dynamic middleName;






@dynamic nimspCandidateID;






@dynamic nimspID;






@dynamic party;






@dynamic photoURL;






@dynamic roles;

- (NSMutableSet*)rolesSet {
	[self willAccessValueForKey:@"roles"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"roles"];
	[self didAccessValueForKey:@"roles"];
	return result;
}





@dynamic sources;






@dynamic stateID;






@dynamic suffixes;






@dynamic transparencyID;






@dynamic votesmartID;






@dynamic districtMap;

	

@dynamic stateObj;

	





@end
