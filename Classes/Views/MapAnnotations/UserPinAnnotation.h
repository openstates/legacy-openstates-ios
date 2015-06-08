//
//  UserPinAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import <MapKit/MapKit.h>
#import "SVPlacemark.h"

#define kUserPinAnnotationAddressChangeKey @"UserPinAnnotationAddressChangeNotification"
@protocol UserPinAnnotationDelegate <NSObject>
@required
- (void)annotationCoordinateChanged:(id)sender;
@end

@interface UserPinAnnotation : SVPlacemark <MKAnnotation> {
}

@property (nonatomic, assign) NSUInteger pinColorIndex;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) id<UserPinAnnotationDelegate> delegate;
-(id)initWithSVPlacemark:(SVPlacemark*)placemark;
- (UIImage *)image;
@end
