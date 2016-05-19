//
//  UserPinAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import <MapKit/MapKit.h>
#import "SLFMapPin.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kUserPinAnnotationAddressChangeKey;

@protocol UserPinAnnotationDelegate <NSObject>
@required
- (void)annotationCoordinateChanged:(id)sender;
@end

@interface UserPinAnnotation : MKPlacemark

@property (nonatomic, assign) SLFMapPinColor pinColorIndex;
@property (nonatomic, copy, nullable) NSString *annotationTitle;
@property (nonatomic, copy, nullable) NSString *annotationSubtitle;
@property (nonatomic, copy, nullable) NSString *imageName;
@property (nonatomic, weak, nullable) id<UserPinAnnotationDelegate> delegate;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
- (nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END

