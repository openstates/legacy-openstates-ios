//
//  UserPinAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import "UserPinAnnotation.h"

#if USE_POSTAL_ADDRESS_FORMAT
@import Contacts;
#endif

NSString * const kUserPinAnnotationAddressChangeKey = @"UserPinAnnotationAddressChangeNotification";

@implementation UserPinAnnotation

@synthesize pinColorIndex = _pinColorIndex;
@synthesize imageName = _imageName;
@synthesize delegate = _delegate;
@synthesize coordinate = _coordinate;

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark
{
    self = [super initWithPlacemark:placemark];
    if (self)
    {
        _pinColorIndex = SLFMapPinColorPurple;
        _coordinate = placemark.location.coordinate;

#if USE_POSTAL_ADDRESS_FORMAT
        [self formatPostalAddress];
#endif

    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

#if USE_POSTAL_ADDRESS_FORMAT

- (void)formatPostalAddress
{
    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
    if (self.subThoroughfare && self.thoroughfare)
        postalAddress.street = [self.subThoroughfare stringByAppendingFormat:@" %@", self.thoroughfare];
    else
        postalAddress.street = self.thoroughfare;
    postalAddress.city = self.locality;
    postalAddress.state = self.administrativeArea;
    postalAddress.postalCode = self.postalCode;
    postalAddress.country = self.country;
    postalAddress.ISOCountryCode = self.ISOcountryCode;

    NSString *formattedAddress = [CNPostalAddressFormatter stringFromPostalAddress:postalAddress style:CNPostalAddressFormatterStyleMailingAddress];
    self.annotationTitle = formattedAddress;
}

#endif

#pragma mark - MKAnnotation properties

- (UIImage *)image
{
    if (!SLFTypeNonEmptyStringOrNil(self.imageName))
    {
        return [UIImage imageNamed:@"silverstar.png"];
    }
    return [UIImage imageNamed:self.imageName];
}

- (NSString *)title
{
    if (SLFTypeNonEmptyStringOrNil(_annotationTitle))
        return _annotationTitle;
    if ([super respondsToSelector:@selector(title)])
    {
        if (SLFTypeNonEmptyStringOrNil(super.title))
            return super.title;
    }
        return super.title;
    return nil;
}

- (NSString *)subtitle
{
    if (SLFTypeNonEmptyStringOrNil(_annotationSubtitle))
        return _annotationSubtitle;
    return NSLocalizedString(@"Tap & hold to move pin", @"");
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    [self willChangeValueForKey:@"coordinate"];
    _coordinate = newCoordinate;
    [self didChangeValueForKey:@"coordinate"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(annotationCoordinateChanged:)])
    {
        [self.delegate performSelector:@selector(annotationCoordinateChanged:) withObject:self];
    }
}

@end
