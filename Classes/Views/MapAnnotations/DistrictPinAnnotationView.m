//
//  DistrictPinAnnotationView.m
//  Created by Gregory Combs on 9/13/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictPinAnnotationView.h"
#import "SLFDistrict.h"
#import "SLFMapPin.h"

NSString* const DistrictPinAnnotationViewReuseIdentifier = @"DistrictPinAnnotationViewID";

@interface DistrictPinAnnotationView()
- (void)setPinColorWithAnnotation:(id <MKAnnotation>)anAnnotation;
- (void)accessoryTapped:(id)sender;
@property (nonatomic,copy) AnnotationOnAccessoryTappedBlock onAccessoryTapped;
@end
    
@implementation DistrictPinAnnotationView
@synthesize accessory;
@synthesize onAccessoryTapped = _onAccessoryTapped;

+ (DistrictPinAnnotationView*)districtPinViewWithAnnotation:(id<MKAnnotation>)annotation identifier:(NSString *)reuseIdentifier {
    return [[[DistrictPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];            
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.animatesDrop = YES;
        self.opaque = NO;
        self.draggable = NO;
        self.canShowCallout = YES;
        [self setPinColorWithAnnotation:annotation];
        self.accessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        self.accessory.enabled = NO;
        self.accessory.exclusiveTouch = YES;
        [self.accessory addTarget:self action:@selector(accessoryTapped:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchCancel];
        self.rightCalloutAccessoryView = self.accessory;
    }
    return self;
}

- (void)dealloc {
    self.accessory = nil;
    Block_release(_onAccessoryTapped);
    [super dealloc];
}

- (void)enableAccessoryWithOnAccessoryTappedBlock:(AnnotationOnAccessoryTappedBlock)block {
    self.accessory.enabled = YES;
    if (block)
        self.onAccessoryTapped = block;
}

- (void)disableAccessory {
    self.accessory.enabled = NO;
//  self.onAccessoryTapped = nil;
}

- (void)setOnAccessoryTapped:(AnnotationOnAccessoryTappedBlock)onAccessoryTapped {
    if (_onAccessoryTapped) {
        Block_release(_onAccessoryTapped);
        _onAccessoryTapped = nil;
    }
    _onAccessoryTapped = Block_copy(onAccessoryTapped);
}

- (void)accessoryTapped:(id)sender {
    if (_onAccessoryTapped)
        _onAccessoryTapped(self, self.accessory);
}

- (void)setPinColorWithAnnotation:(id <MKAnnotation>)anAnnotation {
    if (!anAnnotation || (![anAnnotation isKindOfClass:[SLFDistrict class]]))  
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
    
    NSInteger pinColorIndex = MKPinAnnotationColorRed;
    if ([anAnnotation respondsToSelector:@selector(pinColorIndex)]) {
        NSNumber *pinColorNumber = [anAnnotation performSelector:@selector(pinColorIndex)];
        if (pinColorNumber)
            pinColorIndex = [pinColorNumber integerValue];
    }
        
    if (pinColorIndex < SLFMapPinColorBlue && pinColorIndex >= 0)
        [self setPinColor:pinColorIndex];
    else {
        UIImage *pinImage = [SLFMapPin imageForPinColorIndex:pinColorIndex status:SLFMapPinStatusHead];
        if (pinImage) {
            UIImageView *pinHead = [[UIImageView alloc] initWithImage:pinImage];
            pinHead.tag = 999;
            [self addSubview:pinHead];
            [pinHead release];
        }
    }
    if (![self.annotation respondsToSelector:@selector(image)])
        return;
    UIImage *anImage = [self.annotation performSelector:@selector(image)];
    if (anImage) {
        UIImageView *iconView = [[UIImageView alloc] initWithImage:anImage];
        self.leftCalloutAccessoryView = iconView;
        [iconView release];
    }
}

// MKPinAnnotationView+ZIndexFix
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self.superview bringSubviewToFront:self];
    [super touchesBegan:touches withEvent:event];
}

@end
