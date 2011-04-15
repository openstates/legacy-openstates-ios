// 
//  DistrictMapObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
#import "DistrictMapObj+MapKit.h"

#import "LegislatorObj+RestKit.h"
#import "PolygonMath.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeMapPins.h"

@implementation DistrictMapObj (MapKit)

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
