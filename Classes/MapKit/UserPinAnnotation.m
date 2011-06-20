
//
//  TexLegeAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "UserPinAnnotation.h"
#import "TexLegeAppDelegate.h"
#import <AddressBookUI/ABAddressFormatting.h>
#import "UtilityMethods.h"
@interface UserPinAnnotation (Private)
- (void)reloadTitle;
@end

@implementation UserPinAnnotation

@synthesize pinColorIndex;
@synthesize title, subtitle, imageName, coordinateChangedDelegate;

-(id)initWithSVPlacemark:(SVPlacemark*) placemark {
	self = [super initWithCoordinate:placemark.coordinate addressDictionary:placemark.addressDictionary];
	if (self != nil) {
		pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorPurple]; 
		
		[self reloadTitle];
	}
	return self;
}

- (void)dealloc {	
	self.imageName = nil;
	self.pinColorIndex = nil;
	self.coordinateChangedDelegate = nil;
	self.title = nil;
	self.subtitle = nil;
	[super dealloc];
}

- (void)reloadTitle {
	NSMutableString *formattedAddress = [[NSMutableString alloc] init];

	if (self.addressDictionary) {
		NSString *street = [self.addressDictionary valueForKey:(NSString*)kABPersonAddressStreetKey];
		NSString *city = [self.addressDictionary valueForKey:(NSString*)kABPersonAddressCityKey];
		NSString *state = [self.addressDictionary valueForKey:(NSString*)kABPersonAddressStateKey];
		
		if (NO == IsEmpty(street)) {
			[formattedAddress appendFormat:@"%@, ", street];
		}
		if (NO == IsEmpty(city) && NO == IsEmpty(state)) {
			[formattedAddress appendFormat:@"%@, %@", city, state];
		}		
	}
	if (IsEmpty(formattedAddress)) {
		[formattedAddress appendFormat:@"%f %f", self.coordinate.latitude, self.coordinate.longitude];
	}
	self.title = formattedAddress;
	[formattedAddress release];		
}

#pragma mark -
#pragma mark MKAnnotation properties

- (UIImage *)image {
	if (IsEmpty(self.imageName)) {
		return [UIImage imageNamed:@"silverstar.png"];
	}
	else {
		return [UIImage imageNamed:self.imageName];
	}
}

- (NSString *)subtitle {
	if (!IsEmpty(subtitle)) {
		return subtitle;
	}
	else {
		return NSLocalizedStringFromTable(@"Tap & hold to move pin", @"StandardUI", @"Instructions for moving a location pin on the map");
	}
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	[super setCoordinate:newCoordinate];
	
	self.title = [NSString	stringWithFormat:@"%f %f", newCoordinate.latitude, newCoordinate.longitude];
	
	if (self.coordinateChangedDelegate && [self.coordinateChangedDelegate respondsToSelector:@selector(annotationCoordinateChanged:)]) {
		[self.coordinateChangedDelegate performSelector:@selector(annotationCoordinateChanged:) withObject:self];
	}
}
@end
