// 
//  DistrictMapObj.m
//  Created by Gregory Combs on 8/21/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//
#import "DistrictMapObj+RestKit.h"

#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"
#import "NSData_Base64Extensions.h"

@implementation DistrictMapObj (RestKit)

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"districtMapID", @"districtMapID",
			@"district", @"district",
			@"chamber", @"chamber",
			@"pinColorIndex", @"pinColorIndex",
//			@"lineColor", @"lineColor",
			@"lineWidth", @"lineWidth",
			@"centerLon", @"centerLon",
			@"centerLat", @"centerLat",
			@"spanLon", @"spanLon",
			@"spanLat", @"spanLat",
			@"maxLon", @"maxLon",
			@"maxLat", @"maxLat",
			@"minLon", @"minLon",
			@"minLat", @"minLat",
			@"numberOfCoords", @"numberOfCoords",
//			@"coordinatesData", @"coordinatesData",
			@"updated", @"updated",
			@"coordinatesBase64", @"coordinatesBase64",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"districtMapID";
}

#pragma mark Property Accessor Issues
/* These methods are the exact same thing (or at least *should* be the same) as the default core data object methods
 However, for whatever reason, sometimes the default returns an NSNumber instead of an NSString ... this makes sure */
- (NSString *)updated {
	[self willAccessValueForKey:@"updated"];
	NSString *outValue = [self primitiveValueForKey:@"updated"];
	[self didAccessValueForKey:@"updated"];
	return outValue;
}

- (void)setUpdated:(NSString *)inValue {
	[self willChangeValueForKey:@"updated"];
	[self setPrimitiveValue:inValue forKey:@"updated"];
	[self didChangeValueForKey:@"updated"];
}

#pragma mark -
#pragma mark RestKit Additions

- (void)resetRelationship:(id)sender {
	LegislatorObj * aLegislator = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber];
	self.legislator = aLegislator;
}

- (void) setCoordinatesBase64:(NSString *)newCoords {
	NSString *key = @"coordinatesBase64";
	
	self.coordinatesData = [NSData dataWithBase64EncodedString:newCoords];
	
	[self willChangeValueForKey:key];
	[self setPrimitiveValue:nil forKey:key];
	[self didChangeValueForKey:key];
}

#pragma mark -
#pragma mark Custom

+ (NSArray *)lightPropertiesToFetch {
	NSArray *props = [NSArray arrayWithObjects:
					  @"districtMapID",
					  @"district",
					  @"chamber",
					  @"pinColorIndex",
					  //	@"lineColor",
					  @"lineWidth",
					  @"centerLon",
					  @"centerLat",
					  @"spanLon",
					  @"spanLat",
					  @"maxLon",
					  @"maxLat",
					  @"minLon",
					  @"minLat",
					  @"numberOfCoords",
					  @"updated",
					  @"legislator.lastname",
					  @"legislator.firstname",
					  nil];
	return props;
}

/*
- (void) importFromDictionary: (NSDictionary *)dictionary
{				
	if (dictionary) {
		for (NSString *key in [dictionary allKeys]) {
			if ([key isEqualToString:@"coordinatesData"]) {				
				id data = [dictionary objectForKey:@"coordinatesData"];
				
				if ([data isKindOfClass:[NSString class]]) {   
					self.coordinatesData = [NSData dataWithBase64EncodedString:data];
				}
				else if ([data isKindOfClass:[NSArray class]]) {
					
					NSInteger numberOfPairs = [self.numberOfCoords integerValue];
					CLLocationCoordinate2D *coordinatesCArray = calloc(numberOfPairs, sizeof(CLLocationCoordinate2D));
					NSInteger count = 0;
					if (coordinatesCArray) {
						for (NSArray *spot in data) {
							
							NSNumber *longitude = [spot objectAtIndex:0];
							NSNumber *latitude = [spot objectAtIndex:1];
							
							if (longitude && latitude) {
								double lng = [longitude doubleValue];
								double lat = [latitude doubleValue];
								coordinatesCArray[count++] = CLLocationCoordinate2DMake(lat,lng);
							}
						}
						
						self.coordinatesData = [NSData dataWithBytes:(const void *)coordinatesCArray 
															  length:numberOfPairs*sizeof(CLLocationCoordinate2D)];
						
						free(coordinatesCArray);
					}
				}
				else if ([data isKindOfClass:[NSData class]])
					self.coordinatesData = [data copy];				
			}
			else {
				NSArray *myKeys = [[[self class] elementToPropertyMappings] allKeys];
				if ([myKeys containsObject:key])
					[self setValue:[dictionary objectForKey:key] forKey:key];
			}
		}				
	}
}

- (id) initWithCoder: (NSCoder *)coder
{
	if (self = [super init])
	{
		for (NSString *key in [[[self class] elementToPropertyMappings] allKeys]) {
			if ([key isEqualToString:@"coordinatesData"]) {
				self.coordinatesData = [[coder decodeObjectForKey:@"coordinatesData"] copy];
			}
			else {
				[self setValue:[coder decodeObjectForKey:key] forKey:key];
			}
		}
	}
	return self;
}

- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
	NSDictionary *tempDict = [self exportToDictionary];
	for (NSString *key in [[[self class] elementToPropertyMappings] allKeys]) {
		id object = [tempDict objectForKey:key];
		[coder encodeObject:object];	
	}
}
*/

@end
