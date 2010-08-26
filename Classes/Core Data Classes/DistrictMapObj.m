// 
//  DistrictMapObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//
#import "DistrictMapObj.h"

#import "DistrictOfficeObj.h"
#import "LegislatorObj.h"
#import "PolygonMath.h"

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
//@dynamic districtOffice;
// USE legislator.districtOffices array instead! ... We get plural!



- (NSString *) chamberName {
	
	if ([self.chamber integerValue] == HOUSE)
		return @"House";
	else
		return @"Senate";
}


- (NSString *)title
{
    return [NSString stringWithFormat:@"%@ District %@", [self chamberName], self.district];
}

- (UIImage *)image {
	if (self.legislator && [self.legislator.party_id integerValue] == DEMOCRAT)
		return [UIImage imageNamed:@"bluestar.png"];
	else if (self.legislator && [self.legislator.party_id integerValue] == REPUBLICAN)
		return [UIImage imageNamed:@"redstar.png"];
	else
		return [UIImage imageNamed:@"silverstar.png"];
}

// optional
- (NSString *)subtitle
{
	return [self.legislator legProperName];
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
	
	//self.coordinatesData = [NSData dataWithBytes:(const void *)self.coordinatesCArray 
	//									  length:numberOfPairs*sizeof(CLLocationCoordinate2D)];

	MKPolyline *polyLine=[MKPolyline polylineWithCoordinates:(CLLocationCoordinate2D *)[self.coordinatesData bytes] 
													   count:[self.numberOfCoords integerValue]];
	polyLine.title = self.title;
	polyLine.subtitle = self.subtitle;
	return polyLine;
}

- (MKPolygon *)polygon {
	
	//self.coordinatesData = [NSData dataWithBytes:(const void *)self.coordinatesCArray 
	//									  length:numberOfPairs*sizeof(CLLocationCoordinate2D)];
	
	MKPolygon *polyGon=[MKPolygon polygonWithCoordinates:(CLLocationCoordinate2D *)[self.coordinatesData bytes] 
													   count:[self.numberOfCoords integerValue]];
	polyGon.title = self.title;
	polyGon.subtitle = self.subtitle;
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
