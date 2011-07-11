
//
//  TexLegeAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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
