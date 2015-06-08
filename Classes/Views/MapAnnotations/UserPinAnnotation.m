//
//  UserPinAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import "UserPinAnnotation.h"
#import <AddressBookUI/ABAddressFormatting.h>

@interface UserPinAnnotation()
- (void)reloadTitle;
@end

@implementation UserPinAnnotation

@synthesize pinColorIndex;
@synthesize title, subtitle, imageName, delegate;

-(id)initWithSVPlacemark:(SVPlacemark*) placemark {
    self = [super initWithCoordinate:placemark.coordinate addressDictionary:placemark.addressDictionary];
    if (self) {
        pinColorIndex = MKPinAnnotationColorPurple; 
        [self reloadTitle];
    }
    return self;
}

- (void)dealloc {    
    self.imageName = nil;
    self.delegate = nil;
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
    return [UIImage imageNamed:self.imageName];
}

- (NSString *)subtitle {
    if (IsEmpty(subtitle)) {
        return NSLocalizedString(@"Tap & hold to move pin", @"");
    }
    return subtitle;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    [super setCoordinate:newCoordinate];
    self.title = [NSString    stringWithFormat:@"%f %f", newCoordinate.latitude, newCoordinate.longitude];
    if (self.delegate && [self.delegate respondsToSelector:@selector(annotationCoordinateChanged:)]) {
        [self.delegate performSelector:@selector(annotationCoordinateChanged:) withObject:self];
    }
}
@end
