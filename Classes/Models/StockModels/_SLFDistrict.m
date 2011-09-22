// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SLFDistrict.m instead.

#import "_SLFDistrict.h"

@implementation SLFDistrictID
@end

@implementation _SLFDistrict

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SLFDistrict" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SLFDistrict";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SLFDistrict" inManagedObjectContext:moc_];
}

- (SLFDistrictID*)objectID {
	return (SLFDistrictID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"numSeatsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numSeats"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic boundaryID;






@dynamic chamber;






@dynamic name;






@dynamic numSeats;



- (short)numSeatsValue {
	NSNumber *result = [self numSeats];
	return [result shortValue];
}

- (void)setNumSeatsValue:(short)value_ {
	[self setNumSeats:[NSNumber numberWithShort:value_]];
}

- (short)primitiveNumSeatsValue {
	NSNumber *result = [self primitiveNumSeats];
	return [result shortValue];
}

- (void)setPrimitiveNumSeatsValue:(short)value_ {
	[self setPrimitiveNumSeats:[NSNumber numberWithShort:value_]];
}





@dynamic regionDictionary;






@dynamic shape;






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
