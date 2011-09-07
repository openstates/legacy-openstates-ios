// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFState.m instead.

#import "_SLFState.h"

@implementation SLFStateID
@end

@implementation _SLFState

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFState" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFState";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFState" inManagedObjectContext:moc_];
}

- (SLFStateID*)objectID {
	return (SLFStateID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"lowerChamberTermValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lowerChamberTerm"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"upperChamberTermValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"upperChamberTerm"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic stateID;






@dynamic dateUpdated;






@dynamic featureFlags;






@dynamic legislatureName;






@dynamic level;






@dynamic lowerChamberName;






@dynamic lowerChamberTerm;



- (short)lowerChamberTermValue {
	NSNumber *result = [self lowerChamberTerm];
	return [result shortValue];
}

- (void)setLowerChamberTermValue:(short)value_ {
	[self setLowerChamberTerm:[NSNumber numberWithShort:value_]];
}

- (short)primitiveLowerChamberTermValue {
	NSNumber *result = [self primitiveLowerChamberTerm];
	return [result shortValue];
}

- (void)setPrimitiveLowerChamberTermValue:(short)value_ {
	[self setPrimitiveLowerChamberTerm:[NSNumber numberWithShort:value_]];
}





@dynamic lowerChamberTitle;






@dynamic name;






@dynamic sessionDetails;






@dynamic terms;






@dynamic upperChamberName;






@dynamic upperChamberTerm;



- (short)upperChamberTermValue {
	NSNumber *result = [self upperChamberTerm];
	return [result shortValue];
}

- (void)setUpperChamberTermValue:(short)value_ {
	[self setUpperChamberTerm:[NSNumber numberWithShort:value_]];
}

- (short)primitiveUpperChamberTermValue {
	NSNumber *result = [self primitiveUpperChamberTerm];
	return [result shortValue];
}

- (void)setPrimitiveUpperChamberTermValue:(short)value_ {
	[self setPrimitiveUpperChamberTerm:[NSNumber numberWithShort:value_]];
}





@dynamic upperChamberTitle;






@dynamic bills;

	
- (NSMutableSet*)billsSet {
	[self willAccessValueForKey:@"bills"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"bills"];
	[self didAccessValueForKey:@"bills"];
	return result;
}
	

@dynamic committees;

	
- (NSMutableSet*)committeesSet {
	[self willAccessValueForKey:@"committees"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"committees"];
	[self didAccessValueForKey:@"committees"];
	return result;
}
	

@dynamic districts;

	
- (NSMutableSet*)districtsSet {
	[self willAccessValueForKey:@"districts"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"districts"];
	[self didAccessValueForKey:@"districts"];
	return result;
}
	

@dynamic events;

	
- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];
	[self didAccessValueForKey:@"events"];
	return result;
}
	

@dynamic legislators;

	
- (NSMutableSet*)legislatorsSet {
	[self willAccessValueForKey:@"legislators"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"legislators"];
	[self didAccessValueForKey:@"legislators"];
	return result;
}
	





@end
