//
//  UserPinAnnotationView.m
//  Created by Gregory Combs on 9/7/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
// This work is licensed under the BSD-3 License included with this source
// distribution.

#import "UserPinAnnotationView.h"
#import "UserPinAnnotation.h"
#import "SLFMapPin.h"

NSString* const UserPinReuseIdentifier = @"UserPinReuse";

@interface UserPinAnnotationView()
- (void)annotationChanged_:(NSNotification *)notification;
@end

@implementation UserPinAnnotationView

+ (UserPinAnnotationView*)pinViewWithAnnotation:(id<MKAnnotation>)annotation  {
    return [[UserPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:UserPinReuseIdentifier];            
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.animatesDrop = YES;
        self.opaque = NO;
        self.draggable = YES;
        
        if (![annotation isKindOfClass:[UserPinAnnotation class]])  
            return self;
        
        UserPinAnnotation *customAnnotation = (UserPinAnnotation *)annotation;
        self.canShowCallout = YES;
        
        SLFMapPinColor pinColorIndex = customAnnotation.pinColorIndex;

        UIColor *tint = self.pinTintColor;
        switch (pinColorIndex) {
            case SLFMapPinColorRed:
                tint = [MKPinAnnotationView redPinColor];
                break;
            case SLFMapPinColorBlue:
                tint = [UIColor blueColor];
                break;
            case SLFMapPinColorGreen:
                tint = [MKPinAnnotationView greenPinColor];
                break;
            case SLFMapPinColorPurple:
            default:
                tint = [MKPinAnnotationView purplePinColor];
                break;
        }
        self.pinTintColor = tint;

        UIImage *anImage = [customAnnotation image];
        if (anImage) {
            UIImageView *iconView = [[UIImageView alloc] initWithImage:anImage];
            self.leftCalloutAccessoryView = iconView;
        }            
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationChanged_:) name:kUserPinAnnotationAddressChangeKey object:annotation];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)annotationChanged_:(NSNotification *)notification {
    [self setNeedsDisplay];
}
    
// MKPinAnnotationView+ZIndexFix
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self.superview bringSubviewToFront:self];
    [super touchesBegan:touches withEvent:event];
}

@end
