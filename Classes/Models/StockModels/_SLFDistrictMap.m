// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFDistrictMap.m instead.

#import "_SLFDistrictMap.h"

@implementation SLFDistrictMapID
@end

@implementation _SLFDistrictMap

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFDistrictMap" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFDistrictMap";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFDistrictMap" inManagedObjectContext:moc_];
}

- (SLFDistrictMapID*)objectID {
	return (SLFDistrictMapID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"districtNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"districtNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"externalIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"externalID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic boundaryKind;






@dynamic boundarySet;






@dynamic centroidCoords;






@dynamic chamber;






@dynamic districtNumber;



- (short)districtNumberValue {
	NSNumber *result = [self districtNumber];
	return [result shortValue];
}

- (void)setDistrictNumberValue:(short)value_ {
	[self setDistrictNumber:[NSNumber numberWithShort:value_]];
}

- (short)primitiveDistrictNumberValue {
	NSNumber *result = [self primitiveDistrictNumber];
	return [result shortValue];
}

- (void)setPrimitiveDistrictNumberValue:(short)value_ {
	[self setPrimitiveDistrictNumber:[NSNumber numberWithShort:value_]];
}





@dynamic externalID;



- (int)externalIDValue {
	NSNumber *result = [self externalID];
	return [result intValue];
}

- (void)setExternalIDValue:(int)value_ {
	[self setExternalID:[NSNumber numberWithInt:value_]];
}

- (int)primitiveExternalIDValue {
	NSNumber *result = [self primitiveExternalID];
	return [result intValue];
}

- (void)setPrimitiveExternalIDValue:(int)value_ {
	[self setPrimitiveExternalID:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic resourceURL;






@dynamic shape;






@dynamic slug;






@dynamic stateID;






@dynamic legislators;

	
- (NSMutableSet*)legislatorsSet {
	[self willAccessValueForKey:@"legislators"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"legislators"];
	[self didAccessValueForKey:@"legislators"];
	return result;
}
	

@dynamic state;

	





@end
