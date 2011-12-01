//
//  ColorPinAnnotationView.m
//  Created by Greg Combs on 11/30/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "ColorPinAnnotationView.h"
#import "SLFMapPin.h"

NSString* const ColorPinReuseIdentifier = @"ColorPinReuse";

@interface ColorPinAnnotationView()
@end

@implementation ColorPinAnnotationView

+ (ColorPinAnnotationView*)pinViewWithAnnotation:(NSObject <MKAnnotation> *)annotation {
    return [[[ColorPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ColorPinReuseIdentifier] autorelease];            
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.animatesDrop = YES;
        self.opaque = NO;
        self.draggable = NO;
        self.canShowCallout = NO; // we use the MultiRowCallout classes, which do their own thing
        [self setPinColorWithAnnotation:annotation];
    }
    return self;
}

- (void)setPinColorWithAnnotation:(NSObject <MKAnnotation> *)anAnnotation {
    if ( !anAnnotation || NO == [anAnnotation respondsToSelector:@selector(pinColorIndex)] )  
        return;
    UIView *foundPinImage = nil;
    for (UIView* suspect in self.subviews) {
        if (suspect.tag == 999) {
            foundPinImage = suspect;
            break;
        }
    }
    if (foundPinImage)
        [foundPinImage removeFromSuperview];
    
    id indexValue = [anAnnotation valueForKey:@"pinColorIndex"];
    NSUInteger pinColorIndex = [indexValue unsignedIntegerValue];
    
    if (pinColorIndex < SLFMapPinColorBlue)
        self.pinColor = (MKPinAnnotationColor)pinColorIndex;
    else {
        UIImage *pinImage = [SLFMapPin imageForPinColorIndex:pinColorIndex status:SLFMapPinStatusHead];
        UIImageView *pinHead = [[UIImageView alloc] initWithImage:pinImage];
        pinHead.tag = 999;
        [self addSubview:pinHead];
        [pinHead release];
    }
}

    // MKPinAnnotationView+ZIndexFix
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self.superview bringSubviewToFront:self];
    [super touchesBegan:touches withEvent:event];
}

@end
