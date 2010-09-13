
//
//  CustomAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CustomAnnotation.h"
#import	"BSKmlResult.h"
#import "TexLegeAppDelegate.h"
#import <AddressBookUI/ABAddressFormatting.h>

@interface CustomAnnotation (Private)

- (void)reloadTitle;

@end

@implementation CustomAnnotation

@synthesize pinColorIndex, regionDict, addressDict, title, subtitle, imageName, coordinateChangedDelegate;

-(id)initWithRegion:(MKCoordinateRegion) newRegion {
	self = [super init];
	if (self != nil) {
		self.regionDict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithDouble:newRegion.center.latitude], @"latitude",
						   [NSNumber numberWithDouble:newRegion.center.longitude], @"longitude",
						   [NSNumber numberWithDouble:newRegion.span.latitudeDelta], @"spanLat",
						   [NSNumber numberWithDouble:newRegion.span.longitudeDelta], @"spanLon", nil];
		
		
//		self.addressDict = newRegion.addressDict;
		
		self.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorPurple]; 
		self.imageName = @"silverstar.png";
		
		[self reloadTitle];
	}
	
	return self;
}

-(id)initWithBSKmlResult:(BSKmlResult*) kmlResult {
	self = [super init];
	
	if (self != nil) {		
		self.regionDict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithDouble:kmlResult.latitude], @"latitude",
						   [NSNumber numberWithDouble:kmlResult.longitude], @"longitude",
						   [NSNumber numberWithDouble:kmlResult.coordinateSpan.latitudeDelta], @"spanLat",
						   [NSNumber numberWithDouble:kmlResult.coordinateSpan.longitudeDelta], @"spanLon", nil];
						   
		
		self.addressDict = kmlResult.addressDict;
		
		self.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorPurple]; 
		self.imageName = @"silverstar.png";
		
		[self reloadTitle];
	}
	
	return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.subtitle = [coder decodeObjectForKey:@"subtitle"];
        self.imageName = [coder decodeObjectForKey:@"imageName"];
        self.pinColorIndex = [coder decodeObjectForKey:@"pinColorIndex"];
        self.regionDict = [coder decodeObjectForKey:@"regionDict"];
        self.addressDict = [coder decodeObjectForKey:@"addressDict"];
		
		if (!self.title || ![self.title length])
			[self reloadTitle];
    }
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.title		forKey:@"title"];
	[coder encodeObject:self.subtitle	forKey:@"subtitle"];
	[coder encodeObject:self.imageName	forKey:@"imageName"];
    [coder encodeObject:self.pinColorIndex	forKey:@"pinColorIndex"];
	[coder encodeObject:self.regionDict		forKey:@"regionDict"];
	[coder encodeObject:self.addressDict	forKey:@"addressDict"];
	
}	

- (void)dealloc {	
	self.imageName = nil;
	self.pinColorIndex = nil;
	self.regionDict = nil;
	self.addressDict = nil;
	self.coordinateChangedDelegate = nil;
	[super dealloc];
}

- (void)reloadTitle {
	if (self.addressDict) {
		NSString *formattedString = [self.addressDict objectForKey:@"formattedAddress"];
		NSString *componentString = [self.addressDict objectForKey:@"address"];
	
		if (componentString && [componentString length])
			self.title = componentString;
		else if (formattedString && [formattedString length])
			self.title = formattedString;
		
		return;
	}
	self.title = [NSString	stringWithFormat:@"%f %f", self.coordinate.latitude, self.coordinate.longitude];
		
}

#pragma mark -
#pragma mark MKAnnotation properties

- (UIImage *)image {
	if (!self.imageName || ![self.imageName length])
		return [UIImage imageNamed:@"silverstar.png"];
	else 
		return [UIImage imageNamed:self.imageName];
}

- (NSString *)subtitle {
	if (subtitle)
		return subtitle;
	else
		return @"Tap & hold to move pin";
}

- (CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D tempCoord;
	if (self.regionDict) {
		tempCoord.latitude = [[self.regionDict objectForKey:@"latitude"] doubleValue];
		tempCoord.longitude = [[self.regionDict objectForKey:@"longitude"] doubleValue];
	}
	return tempCoord;
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
	
	[tempDict setObject:[NSNumber numberWithDouble:newCoordinate.latitude] forKey:@"latitude"];
	[tempDict setObject:[NSNumber numberWithDouble:newCoordinate.longitude] forKey:@"longitude"];
	if (self.regionDict) {
		NSNumber *tempNum = [self.regionDict objectForKey:@"spanLat"];
		if (tempNum)
			[tempDict setObject:tempNum forKey:@"spanLat"];
		tempNum = [self.regionDict objectForKey:@"spanLon"];
		if (tempNum)
			[tempDict setObject:tempNum forKey:@"spanLon"];
	}
	
	self.regionDict = tempDict;
	[tempDict release];
		
	//self.title = @"Updating Address...";
	self.title = [NSString	stringWithFormat:@"%f %f", newCoordinate.latitude, newCoordinate.longitude];
	
	if (self.coordinateChangedDelegate && [self.coordinateChangedDelegate respondsToSelector:@selector(annotationCoordinateChanged:)])
		[self.coordinateChangedDelegate performSelector:@selector(annotationCoordinateChanged:) withObject:self];
}


- (MKCoordinateSpan) span {
	return MKCoordinateSpanMake([[self.regionDict objectForKey:@"spanLat"] doubleValue],
								[[self.regionDict objectForKey:@"spanLon"] doubleValue]);
}

- (MKCoordinateRegion)region {
	return MKCoordinateRegionMake(self.coordinate, self.span);
}

- (void)setAddressDictWithPlacemark:(MKPlacemark *)placemark {
	if (!placemark)
		return;
	
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:placemark.addressDictionary];
	
	if (placemark.thoroughfare)
		[tempDict setObject:placemark.thoroughfare forKey:@"address"];
	
	if (placemark.locality)
		[tempDict setObject:placemark.locality forKey:@"city"];
	
	if (placemark.country)
		[tempDict setObject:placemark.locality forKey:@"country"];
	
	if (placemark.countryCode)
		[tempDict setObject:placemark.countryCode forKey:@"countryCode"];
	
	if (placemark.subAdministrativeArea)
		[tempDict setObject:placemark.subAdministrativeArea forKey:@"county"];
	
	if (placemark.administrativeArea)
		[tempDict setObject:placemark.administrativeArea forKey:@"state"];
	
	if (placemark.administrativeArea)
		[tempDict setObject:placemark.administrativeArea forKey:@"stateCode"];
	
	if (placemark.postalCode)
		[tempDict setObject:placemark.postalCode forKey:@"zip"];
	
	
	//////////
	NSString *formatted = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
	if (formatted)
		[tempDict setObject:formatted forKey:@"formattedAddress"];
	
	self.addressDict = tempDict;
	
	[self reloadTitle];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kCustomAnnotationAddressChangeNotificationKey object:self];
}

@end
