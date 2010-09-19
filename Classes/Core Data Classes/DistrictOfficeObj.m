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
#import "TexLegeCoreDataUtils.h"
#import "TexLegeMapPins.h"

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


- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.district = [coder decodeObjectForKey:@"district"];
        self.chamber = [coder decodeObjectForKey:@"chamber"];
		self.pinColorIndex = [coder decodeObjectForKey:@"pinColorIndex"];
		self.longitude = [coder decodeObjectForKey:@"longitude"];
		self.latitude = [coder decodeObjectForKey:@"latitude"];
		self.spanLon = [coder decodeObjectForKey:@"spanLon"];
		self.spanLat = [coder decodeObjectForKey:@"spanLat"];
		self.stateCode = [coder decodeObjectForKey:@"stateCode"];
		self.formattedAddress = [coder decodeObjectForKey:@"formattedAddress"];
		self.address = [coder decodeObjectForKey:@"address"];
		self.city = [coder decodeObjectForKey:@"city"];
		self.county = [coder decodeObjectForKey:@"county"];
		self.phone = [coder decodeObjectForKey:@"phone"];
		self.fax = [coder decodeObjectForKey:@"fax"];
		self.zipCode = [coder decodeObjectForKey:@"zipCode"];
		
		NSNumber *legislatorID = [coder decodeObjectForKey:@"legislatorID"];
		if (legislatorID)
			self.legislator = [TexLegeCoreDataUtils legislatorWithLegislatorID:legislatorID withContext:[self managedObjectContext]];
		else
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
		self.longitude = [dictionary objectForKey:@"longitude"];
		self.latitude = [dictionary objectForKey:@"latitude"];
		self.spanLon = [dictionary objectForKey:@"spanLon"];
		self.spanLat = [dictionary objectForKey:@"spanLat"];
		self.stateCode = [dictionary objectForKey:@"stateCode"];
		self.formattedAddress = [dictionary objectForKey:@"formattedAddress"];
		self.address = [dictionary objectForKey:@"address"];
		self.city = [dictionary objectForKey:@"city"];
		self.county = [dictionary objectForKey:@"county"];
		self.phone = [dictionary objectForKey:@"phone"];
		self.fax = [dictionary objectForKey:@"fax"];
		self.zipCode = [dictionary objectForKey:@"zipCode"];
		
		NSNumber *legislatorID = [dictionary objectForKey:@"legislatorID"];
		if (legislatorID)
			self.legislator = [TexLegeCoreDataUtils legislatorWithLegislatorID:legislatorID withContext:[self managedObjectContext]];
		else
			self.legislator = [TexLegeCoreDataUtils legislatorForDistrict:self.district andChamber:self.chamber withContext:[self managedObjectContext]];		
	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.district, @"district",
							  self.chamber, @"chamber",
							  self.pinColorIndex, @"pinColorIndex",
							  self.longitude, @"longitude",
							  self.latitude, @"latitude",
							  self.spanLon, @"spanLon",
							  self.spanLat, @"spanLat",
							  self.stateCode, @"stateCode",
							  self.formattedAddress, @"formattedAddress",
							  self.address, @"address",
							  self.city, @"city",
							  self.county, @"county",
							  self.phone, @"phone",
							  self.fax, @"fax",
							  self.zipCode, @"zipCode",
							  self.legislator.legislatorID, @"legislatorID",
							  nil];
	return tempDict;
}

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
