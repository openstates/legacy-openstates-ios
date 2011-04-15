// 
//  DistrictOfficeObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictOfficeObj+MapKit.h"

#import "LegislatorObj+RestKit.h"
#import "TexLegeMapPins.h"

@implementation DistrictOfficeObj (MapKit)

// we're overriding what's stored in core data ... is this a good idea?
- (NSNumber *) pinColorIndex {
	/*	if (self.legislator) {
	 if ([self.legislator.party_id integerValue] == REPUBLICAN)
	 return [NSNumber numberWithInteger:TexLegePinAnnotationColorRed];
	 else if ([self.legislator.party_id integerValue] == DEMOCRAT)
	 return [NSNumber numberWithInteger:TexLegePinAnnotationColorBlue];
	 }
	 return [NSNumber numberWithInteger:TexLegePinAnnotationColorGreen];
	 */
	return [NSNumber numberWithInteger:TexLegePinAnnotationColorGreen];
}

#pragma mark -
#pragma mark MKAnnotation properties

- (NSString *)title
{
	if (!self.legislator)
		return @"District Office";

	NSString *tempString = [NSString stringWithFormat:@"%@ %@ (%@)", [self.legislator legTypeShortName], [self.legislator legProperName], [self.legislator partyShortName]];
    return tempString;
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
	//debug_NSLog(@"addressDict: %@", self.addressDict);
	NSString *formattedString = self.formattedAddress;
	NSString *componentString = self.address;
	
	if (!formattedString && !componentString)
		return nil;
	
	/*
	 NSInteger formattedLength = [formattedString length];
	 NSRange strRange = NSMakeRange(NSNotFound, 0);
	 if (formattedString && formattedLength)
	 strRange = [formattedString rangeOfString:@","];
	 if (strRange.length > 0 && strRange.location < formattedLength)
	 formattedString = [formattedString substringToIndex:strRange.location];
	 */
	if (formattedString && [formattedString length])
		return formattedString;
	else {
		//debug_NSLog(@"formatted address not found, using component address: %@", componentString);
		return componentString;
	}
}

- (CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D tempCoord = {[self.latitude doubleValue],[self.longitude doubleValue]};
	return tempCoord;
}

- (MKCoordinateSpan) span {
	return MKCoordinateSpanMake([self.spanLat doubleValue], [self.spanLon doubleValue]);
}

- (MKCoordinateRegion)region {
	return MKCoordinateRegionMake([self coordinate], [self span]);
}

- (NSString *)cellAddress {
	NSString *tempString = [NSString stringWithFormat:@"%@\n%@, %@\n%@", 
							[self.address stringByReplacingOccurrencesOfString:@", " withString:@"\n"], 
							self.city, self.stateCode, self.zipCode];
	return tempString;
}

@end
