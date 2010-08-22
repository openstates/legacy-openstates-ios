// 
//  DistrictOfficeObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "DistrictOfficeObj.h"

#import "DistrictMapObj.h"
#import "LegislatorObj.h"

@implementation DistrictOfficeObj 

@dynamic chamber;
@dynamic spanLat;
@dynamic pinColorIndex;
@dynamic longitude;
@dynamic stateCode;
@dynamic latitude;
@dynamic formattedAddress;
@dynamic address;
@dynamic city;
@dynamic county;
@dynamic phone;
@dynamic fax;
@dynamic district;
@dynamic spanLon;
@dynamic zipCode;
@dynamic legislator;
@dynamic districtMap;


#pragma mark -
#pragma mark MKAnnotation properties

- (NSString *)title
{
	if (!self.legislator)
		return @"District Office";
	
    return [self.legislator legProperName];
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
	
	NSInteger formattedLength = [formattedString length];
	NSRange range = [formattedString rangeOfString:@","];
	if (range.length > 0 && range.location != NSNotFound && range.location < formattedLength)
		formattedString = [formattedString substringToIndex:range.location];
	
	if (formattedString && [formattedString length])
		return formattedString;
	else {
		debug_NSLog(@"formatted address not found, using component address: %@", componentString);
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
