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
@dynamic legislator;
@dynamic pinColorIndex;

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.district = [coder decodeObjectForKey:@"district"];
        self.chamber = [coder decodeObjectForKey:@"chamber"];
		self.pinColorIndex = [coder decodeObjectForKey:@"pinColorIndex"];
		self.lineColor = [coder decodeObjectForKey:@"lineColor"];
		self.lineWidth = [coder decodeObjectForKey:@"lineWidth"];
		self.centerLon = [coder decodeObjectForKey:@"centerLon"];
		self.centerLat = [coder decodeObjectForKey:@"centerLat"];
		self.spanLon = [coder decodeObjectForKey:@"spanLon"];
		self.spanLat = [coder decodeObjectForKey:@"spanLat"];
		self.maxLon = [coder decodeObjectForKey:@"maxLon"];
		self.maxLat = [coder decodeObjectForKey:@"maxLat"];
		self.minLon = [coder decodeObjectForKey:@"minLon"];
		self.minLat = [coder decodeObjectForKey:@"minLat"];
		self.numberOfCoords = [coder decodeObjectForKey:@"numberOfCoords"];
		self.coordinatesData = [[coder decodeObjectForKey:@"coordinatesData"] copy];
		
		self.legislator = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber withContext:[self managedObjectContext]];		
    }
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder;
{
	NSDictionary *tempDict = [self exportToDictionary];
	for (NSString *key in [tempDict allKeys]) {
		id object = [tempDict objectForKey:key];
		[coder encodeObject:object];	
	}
}

- (void) importFromDictionary: (NSDictionary *)dictionary
{				
	if (dictionary) {
		self.district = [dictionary objectForKey:@"district"];
		self.chamber = [dictionary objectForKey:@"chamber"];
		self.pinColorIndex = [dictionary objectForKey:@"pinColorIndex"];
		//self.lineColor = [dictionary objectForKey:@"lineColor"];
		self.lineWidth = [dictionary objectForKey:@"lineWidth"];
		self.centerLon = [dictionary objectForKey:@"centerLon"];
		self.centerLat = [dictionary objectForKey:@"centerLat"];
		self.spanLon = [dictionary objectForKey:@"spanLon"];
		self.spanLat = [dictionary objectForKey:@"spanLat"];
		self.maxLon = [dictionary objectForKey:@"maxLon"];
		self.maxLat = [dictionary objectForKey:@"maxLat"];
		self.minLon = [dictionary objectForKey:@"minLon"];
		self.minLat = [dictionary objectForKey:@"minLat"];
		self.numberOfCoords = [dictionary objectForKey:@"numberOfCoords"];
		
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


		self.legislator = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber withContext:[self managedObjectContext]];		
	}
}


- (NSDictionary *)exportToDictionary {
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
	[tempDict setObject:self.district forKey:@"district"];
	[tempDict setObject:self.chamber forKey:@"chamber"];
	[tempDict setObject:self.pinColorIndex forKey:@"pinColorIndex"];
//	[tempDict setObject:self.lineColor forKey:@"lineColor"];
	[tempDict setObject:self.lineWidth forKey:@"lineWidth"];
	[tempDict setObject:self.centerLon forKey:@"centerLon"];
	[tempDict setObject:self.centerLat forKey:@"centerLat"];
	[tempDict setObject:self.spanLon forKey:@"spanLon"];
	[tempDict setObject:self.spanLat forKey:@"spanLat"];
	[tempDict setObject:self.maxLon forKey:@"maxLon"];
	[tempDict setObject:self.maxLat forKey:@"maxLat"];
	[tempDict setObject:self.minLon forKey:@"minLon"];
	[tempDict setObject:self.minLat forKey:@"minLat"];
	[tempDict setObject:self.numberOfCoords forKey:@"numberOfCoords"];
	//[tempDict setObject:self.legislator.legislatorID forKey:@"legislatorID"];
	
	[tempDict setObject:self.coordinatesData forKey:@"coordinatesData"];

	return tempDict;
}

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
	@"district",
	@"chamber",
	@"pinColorIndex",
	@"lineColor",
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
	@"legislator.legislatorID",
	@"legislator.firstname",
	@"legislator.lastname",
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
		
		DistrictMapObj *interiorDistrict = [TexLegeCoreDataUtils districtMapForDistrict:[NSNumber numberWithInt:84] 
																	 andChamber:self.chamber 
																	withContext:[self managedObjectContext]];
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

	if (![self boundingBoxContainsCoordinate:aCoordinate])
		return NO;
	
	return [PolygonMath insidePolygon:(CLLocationCoordinate2D *)[self.coordinatesData bytes]
						 count:[self.numberOfCoords integerValue] point:aCoordinate];

}


@end
