/*
 File: DistrictMap.m
 Abstract: The model class that stores the information about an districtMap.
 */

#if NEEDS_TO_PARSE_KMLMAPS == 1

#import "DistrictMap.h"

@interface DistrictMap (Private)

- (void)calculateRegion;

@end

@implementation DistrictMap

@synthesize district, chamber, regionDict, lineWidth, lineColor;
@synthesize coordinatesCArray, numberOfCoords, coordinatesData, boundingBox, legislatorID;

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
		coordinatesCArray = NULL;
        self.district = [coder decodeObjectForKey:@"district"];
        self.chamber = [coder decodeObjectForKey:@"chamber"];
        self.lineColor = [coder decodeObjectForKey:@"lineColor"];
        self.lineWidth = [coder decodeObjectForKey:@"lineWidth"];
        self.legislatorID = [coder decodeObjectForKey:@"legislatorID"];
        self.regionDict = [coder decodeObjectForKey:@"regionDict"];
		self.boundingBox = [coder decodeObjectForKey:@"boundingBox"];
        self.numberOfCoords = [coder decodeObjectForKey:@"numberOfCoords"];
        self.coordinatesData = [coder decodeObjectForKey:@"coordinatesData"];
		
		NSInteger numberOfPairs = [self.numberOfCoords integerValue];
		NSUInteger len = (sizeof(CLLocationCoordinate2D) * numberOfPairs);
		CLLocationCoordinate2D * temp = (CLLocationCoordinate2D * )[coder decodeBytesForKey:@"coordinatesCArray" returnedLength:&len];
		coordinatesCArray = calloc(numberOfPairs, sizeof(CLLocationCoordinate2D));
		
        for (NSInteger index = 0; index < numberOfPairs; index++) {
            coordinatesCArray[index] = temp[index];
        }
    }
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.district		forKey:@"district"];
    [coder encodeObject:self.chamber		forKey:@"chamber"];
    [coder encodeObject:self.lineColor		forKey:@"lineColor"];
    [coder encodeObject:self.lineWidth		forKey:@"lineWidth"];
	[coder encodeObject:self.legislatorID	forKey:@"legislatorID"];
	[coder encodeObject:self.boundingBox	forKey:@"boundingBox"];
	[coder encodeObject:self.regionDict		forKey:@"regionDict"];
    [coder encodeObject:self.numberOfCoords	forKey:@"numberOfCoords"];
	[coder encodeObject:self.coordinatesData forKey:@"coordinatesData"];
    
	NSUInteger len = (sizeof(CLLocationCoordinate2D) * [self.numberOfCoords integerValue]);
	[coder encodeBytes:(const void *)self.coordinatesCArray length:len forKey:@"coordinatesCArray"];
	
}

- (id)init {
	if (self = [super init]) {
		coordinatesCArray = NULL;
		
		self.lineColor = [UIColor redColor];
		self.lineWidth = [NSNumber numberWithFloat:2.0f];
		
	}
	return self;
}
- (void)dealloc {
	if (coordinatesCArray) {
		free(coordinatesCArray);
		coordinatesCArray = NULL;
	}
	self.coordinatesData = nil;
	self.district = nil;
	self.chamber = nil;
	self.lineColor = nil;
	self.lineWidth = nil;
	self.regionDict = nil;
	self.legislatorID = nil;
	self.boundingBox = nil;
	[super dealloc];
}

- (void)setComplete:(BOOL)isComplete {
	if (isComplete) {
		[self calculateRegion];
		
		//NSLog(@"ARCHIVING %@ District: %@", self.chamberName, self.distName);
		//NSString *fileName = [NSString stringWithFormat:@"/Users/greg/Desktop/districts/CoreData/%@-%@.plist", 
		//					  self.chamberName, self.distName];
		//[NSKeyedArchiver archiveRootObject:self toFile:fileName];

	}
}

- (void)calculateRegion {
	// determine the extents of the polyline points that we've accumulated, so that we may zoom in to that area.
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	
	if (!coordinatesCArray)
		return;
	
	for( NSInteger index = 0; index < [self.numberOfCoords integerValue]; index++ ) {
		CLLocationCoordinate2D coord = coordinatesCArray[index];
		CLLocationDegrees lat = coord.latitude;
		CLLocationDegrees lng = coord.longitude;
		
		if (lat > maxLat)
			maxLat = lat;
		if (lat < minLat)
			minLat = lat;
		if (lng > maxLon)
			maxLon = lng;
		if (lng < minLon)
			minLon = lng;
	}
	self.boundingBox = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithDouble:maxLat], @"maxLat",
						[NSNumber numberWithDouble:minLat], @"minLat",
						[NSNumber numberWithDouble:maxLon], @"maxLon",
						[NSNumber numberWithDouble:minLon], @"minLon", nil];
	
	self.regionDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithDouble:((maxLat + minLat) / 2)], @"centerLat",
					   [NSNumber numberWithDouble:((maxLon + minLon) / 2)], @"centerLon",
					   [NSNumber numberWithDouble:(maxLat - minLat)], @"spanLat",
					   [NSNumber numberWithDouble:(maxLon - minLon)], @"spanLon", nil];
}

- (CLLocationCoordinate2D) center {
	CLLocationCoordinate2D tempCoord;
	
	tempCoord.latitude = [[self.regionDict objectForKey:@"centerLat"] doubleValue];
	tempCoord.longitude = [[self.regionDict objectForKey:@"centerLon"] doubleValue];

	return tempCoord;
}

- (MKCoordinateSpan) span {
	return MKCoordinateSpanMake([[self.regionDict valueForKey:@"spanLat"] doubleValue],
								[[self.regionDict valueForKey:@"spanLon"] doubleValue]);
}

- (MKCoordinateRegion)region {
	return MKCoordinateRegionMake(self.center, self.span);
}

#pragma mark -
#pragma mark MKAnnotation Protocol
- (CLLocationCoordinate2D) coordinate {
	return self.center;
}

- (NSString *) chamberName {
	
	if ([self.chamber integerValue] == HOUSE)
		return @"House";
	else
		return @"Senate";
}

- (NSString *)title {
	return [NSString stringWithFormat:@"Texas %@ District %@", self.chamberName, self.district];
}

- (NSString *)subtitle {
	return @"Franklin D. Legislator (R)";
}

#pragma mark -
#pragma mark Polyline C Array

- (void)setCoordinatesCArrayWithDictArray:(NSArray *)dictArray {
	if (!dictArray)
		return;
	
	if (coordinatesCArray) {
		free(coordinatesCArray);
		coordinatesCArray = NULL;
	}
	
	NSInteger numberOfPairs = [dictArray count];
	self.numberOfCoords = [NSNumber numberWithInteger:numberOfPairs];
	coordinatesCArray = calloc(numberOfPairs, sizeof(CLLocationCoordinate2D));
	double lat, lng;
	NSInteger index=0;
	for (NSDictionary *dict in dictArray) {
		lat = [[dict valueForKey:@"latitude"] doubleValue];
		lng = [[dict valueForKey:@"longitude"] doubleValue];
		coordinatesCArray[index++] = CLLocationCoordinate2DMake(lat,lng);
	}

	self.coordinatesData = [NSData dataWithBytes:(const void *)self.coordinatesCArray 
										  length:numberOfPairs*sizeof(CLLocationCoordinate2D)];
	
	NSLog(@"%d", [self.coordinatesData length]);
}

- (MKPolyline *)districtPolyline {
	
	MKPolyline *polyLine=[MKPolyline polylineWithCoordinates:self.coordinatesCArray 
													   count:[self.numberOfCoords integerValue]];
	polyLine.title = [self title];
	polyLine.subtitle = [self subtitle];
	return polyLine;
}

- (NSArray *)points {
	NSMutableArray *tempPoints = [NSMutableArray arrayWithCapacity:[self.numberOfCoords integerValue]];
	
	for( NSInteger index = 0; index < [self.numberOfCoords integerValue]; index++ ) {
		CLLocationCoordinate2D coord = coordinatesCArray[index];
		
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude 
													 longitude:coord.longitude];
		[tempPoints addObject:loc];
		[loc release];
	}
	
	return tempPoints;	
}
@end
#endif

