//
//  ColorPinAnnotationView.m
//  Created by Greg Combs on 11/30/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import "ColorPinAnnotationView.h"
#import "SLFMapPin.h"

NSString* const ColorPinReuseIdentifier = @"ColorPinReuse";

@interface ColorPinAnnotationView()
@end

@implementation ColorPinAnnotationView

+ (instancetype)pinViewWithAnnotation:(NSObject <MKAnnotation> *)annotation {
    return [[ColorPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ColorPinReuseIdentifier];            
}

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.animatesDrop = YES;
        self.opaque = NO;
        self.draggable = NO;
        self.canShowCallout = NO; // we use the MultiRowCallout classes, which do their own thing
        [self setPinColorWithAnnotation:annotation];
    }
    return self;
}

- (void)setPinColorWithAnnotation:(NSObject <MKAnnotation> *)anAnnotation
{
    if (!anAnnotation || ![anAnnotation respondsToSelector:@selector(pinColorIndex)])
        return;

    SLFMapPinColor pinColorIndex = [SLFTypeNumberOrNil([anAnnotation valueForKey:@"pinColorIndex"]) unsignedIntValue];
    UIColor *pinColor = SLFMapPinTintColorForColorIndex(pinColorIndex);
    self.pinTintColor = pinColor;
}

#if 0
    // MKPinAnnotationView+ZIndexFix
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self.superview bringSubviewToFront:self];
    [super touchesBegan:touches withEvent:event];
}

#endif

@end
