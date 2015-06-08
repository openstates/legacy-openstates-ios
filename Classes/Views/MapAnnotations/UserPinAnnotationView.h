//
//  UserPinAnnotationView.h
//  Created by Gregory Combs on 9/7/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import <MapKit/MapKit.h>

@interface UserPinAnnotationView : MKPinAnnotationView
+ (UserPinAnnotationView*)pinViewWithAnnotation:(id<MKAnnotation>)annotation;
@end

extern NSString* const UserPinReuseIdentifier;
