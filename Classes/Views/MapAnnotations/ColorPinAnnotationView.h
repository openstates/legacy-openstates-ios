//
//  ColorPinAnnotationView.h
//  Created by Greg Combs on 11/30/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import <MapKit/MapKit.h>
#import "GenericPinAnnotationView.h"

@interface ColorPinAnnotationView : GenericPinAnnotationView
+ (ColorPinAnnotationView*)pinViewWithAnnotation:(NSObject <MKAnnotation> *)annotation;
- (void)setPinColorWithAnnotation:(NSObject <MKAnnotation> *)anAnnotation;
@end

extern NSString* const ColorPinReuseIdentifier;
