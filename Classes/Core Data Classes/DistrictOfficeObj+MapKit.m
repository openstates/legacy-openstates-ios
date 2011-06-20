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
#import "UtilityMethods.h"

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
	if (!self.legislator) {
		return NSLocalizedStringFromTable(@"District Office", @"DataTableUI", @"The actual office building/address");
	}

    return [NSString stringWithFormat:@"%@ %@ (%@)", 
			[self.legislator legTypeShortName], 
			[self.legislator legProperName], 
			[self.legislator partyShortName]];
}

- (UIImage *)image {
	NSString *imageFile = @"silverstar.png";
	if (self.legislator) {
		if (DEMOCRAT == [self.legislator.party_id integerValue]) {
			imageFile = @"bluestar.png";
		}
		else if ([self.legislator.party_id integerValue] == REPUBLICAN) {
			imageFile = @"redstar.png";
		}
	}
	return [UIImage imageNamed:imageFile];
}

// optional
- (NSString *)subtitle
{	
	if (NO == IsEmpty(self.formattedAddress)) {
		return self.formattedAddress;
	}
	else if (NO == IsEmpty(self.address)){
		return self.address;
	}
	return nil;
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
	NSString *crAddress = [self.address stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
	NSString *tempString = [NSString stringWithFormat:@"%@\n%@, %@\n%@", 
							crAddress, 
							self.city, self.stateCode, self.zipCode];
	return tempString;
}

@end
