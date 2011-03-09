// 
//  DistrictMapObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
#import "DistrictMapObj.h"

#import "DistrictOfficeObj.h"
#import "LegislatorObj.h"
#import "PolygonMath.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeMapPins.h"
#import "NSData_Base64Extensions.h"

@implementation DistrictMapObj 

@dynamic centerLat;
@dynamic centerLon;
@dynamic spanLat;
@dynamic spanLon;
@dynamic maxLat;
@dynamic minLat;
@dynamic maxLon;
@dynamic minLon;
@dynamic chamber;
@dynamic lineWidth;
@dynamic coordinatesData;
@dynamic numberOfCoords;
@dynamic district;
@dynamic lineColor;
@dynamic pinColorIndex;
@dynamic districtMapID;
@dynamic updated;
@dynamic legislator;
@dynamic coordinatesBase64;

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

//#warning Why not also add a new attribute listing the districts or coordinates that this district map contains as internal polygons
+ (NSString*)primaryKeyProperty {
	return @"districtMapID";
}
/*
+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"legislator", @"legislator",
			nil];
}
*/

- (void)resetRelationship:(id)sender {
	LegislatorObj * aLegislator = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber];
	self.legislator = aLegislator;
}

/* (LegislatorObj *)legislator {
	LegislatorObj * aLegislator = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber];
	return aLegislator;
}*/

- (void) setCoordinatesBase64:(NSString *)newCoords {
	NSString *key = @"coordinatesBase64";
	
	self.coordinatesData = [NSData dataWithBase64EncodedString:newCoords];
	
	[self willChangeValueForKey:key];
	[self setPrimitiveValue:nil forKey:key];
	[self didChangeValueForKey:key];
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
/*
- (NSData *)coordinatesData {
#ifdef WE_DONT_CARE_ABOUT_FUTURE_ONLINE_UPDATES_TOTHE_COORDINATES
	NSData *tempData = [self primitiveValueForKey:@"coordinatesData"];
	if (!tempData) {
		tempData = [NSData dataWithBase64EncodedString:self.coordinatesBase64];
		self.coordinatesData = [tempData copy];
	}
#else // WE_ACTUALLY_DO_WANT_TO_UPDATE_COORDINATES_WHEN_NECESSARY
	NSData *tempData = [NSData dataWithBase64EncodedString:self.coordinatesBase64];
#endif
	return tempData;
}
*/
- (id)proxyForJson {	
	NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[self exportToDictionary]];
	
#if JSON_EXPORTS_COORDINATES == 1
	[jsonDict removeObjectForKey:@"coordinatesData"];
	
	CLLocationCoordinate2D *pointsArray = (CLLocationCoordinate2D *)[self.coordinatesData bytes];

	NSInteger i = 0, N = [self.numberOfCoords integerValue];
	
	NSMutableArray *jsonPoints = [NSMutableArray array];
	
	for (i=1;i<=N;i++) {
		CLLocationCoordinate2D point = pointsArray[i % N];
			
		[jsonPoints addObject:[NSArray arrayWithObjects:
							   [NSNumber numberWithDouble:point.longitude], [NSNumber numberWithDouble:point.latitude], nil]];
	}
	
	[jsonDict setObject:jsonPoints forKey:@"coordinatesData"];
#endif
	
    return jsonDict;
}

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

- (NSString *)title
{
	NSString *chamberString = stringForChamber([self.chamber integerValue], TLReturnFull);
	
    return [NSString stringWithFormat:@"%@ District %@", chamberString, self.district];
}

- (UIImage *)image {
	if (self.legislator && [self.legislator.party_id integerValue] == DEMOCRAT)
		return [UIImage imageNamed:@"bluestar.png"];
	else if (self.legislator && [self.legislator.party_id integerValue] == REPUBLICAN)
		return [UIImage imageNamed:@"redstar.png"];
	else
		return [UIImage imageNamed:@"silverstar.png"];
}

/*
- (NSNumber *)pinColorIndex {
	NSNumber *pinColor = nil;
	
	LegislatorObj *tempLege = self.legislator;
	if (!tempLege)
		tempLege = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber withContext:[self managedObjectContext]];

	if (tempLege)
		pinColor = ([tempLege.party_id integerValue] == REPUBLICAN) ? [NSNumber numberWithInteger:TexLegePinAnnotationColorRed] : [NSNumber numberWithInteger:TexLegePinAnnotationColorBlue];
	else
		pinColor = [NSNumber numberWithInteger:TexLegePinAnnotationColorGreen];
		
	return pinColor;
}*/

- (NSString *)subtitle
{
	NSString *tempString = [NSString stringWithFormat:@"%@ %@ (%@)", [self.legislator legTypeShortName], [self.legislator legProperName], [self.legislator partyShortName]];
	return tempString;
}

- (CLLocationCoordinate2D) center {
	CLLocationCoordinate2D point = {[self.centerLat doubleValue], [self.centerLon doubleValue]};
	return point;
}

- (MKCoordinateRegion)region {
	return MKCoordinateRegionMake(self.center, self.span);
}

- (CLLocationCoordinate2D) coordinate {
	return self.center;
}

- (MKCoordinateSpan) span {
	return MKCoordinateSpanMake([self.spanLat doubleValue], [self.spanLon doubleValue]);
}

- (MKPolyline *)polyline {
	
	MKPolyline *polyLine=[MKPolyline polylineWithCoordinates:(CLLocationCoordinate2D *)[self.coordinatesData bytes] 
													   count:[self.numberOfCoords integerValue]];
	polyLine.title = [self title];
	polyLine.subtitle = [self subtitle];
	return polyLine;
}

- (MKPolygon *)polygon {
	MKPolygon *polyGon=nil;
		
	if (self.district && [self.district integerValue] == 83) {	// special case (until districts change)
		NSArray *interiorPolygons = nil;
		
		DistrictMapObj *interiorDistrict = [TexLegeCoreDataUtils districtMapForDistrict:[NSNumber numberWithInt:84] andChamber:self.chamber lightProperties:NO];
		if (interiorDistrict) {
			MKPolygon *interiorPolygon = [interiorDistrict polygon];
			if (interiorPolygon)
				interiorPolygons = [NSArray arrayWithObject:interiorPolygon];
		}
									
		polyGon = [MKPolygon polygonWithCoordinates:(CLLocationCoordinate2D *)[self.coordinatesData bytes] 
											  count:[self.numberOfCoords integerValue] 
								   interiorPolygons:interiorPolygons];
	}
	else
		polyGon = [MKPolygon polygonWithCoordinates:(CLLocationCoordinate2D *)[self.coordinatesData bytes] 
													   count:[self.numberOfCoords integerValue]];
	polyGon.title = [self title];
	polyGon.subtitle = [self subtitle];
	return polyGon;
}

- (BOOL) boundingBoxContainsCoordinate:(CLLocationCoordinate2D)aCoordinate {
	return (aCoordinate.latitude <= [self.maxLat doubleValue] &&
			aCoordinate.latitude >= [self.minLat doubleValue] &&
			aCoordinate.longitude <= [self.maxLon doubleValue] &&
			aCoordinate.longitude >= [self.minLon doubleValue] );
}

- (BOOL) districtContainsCoordinate:(CLLocationCoordinate2D)aCoordinate {

	//if (![self boundingBoxContainsCoordinate:aCoordinate])
	//	return NO;
	
	return [PolygonMath insidePolygon:(CLLocationCoordinate2D *)[[self valueForKey:@"coordinatesData"] bytes]
						 count:[[self valueForKey:@"numberOfCoords"] integerValue] point:aCoordinate];

}


@end
