//
//  DistrictPinAnnotationView.h
//  Created by Gregory Combs on 9/13/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <MapKit/MapKit.h>

typedef void(^AnnotationOnAccessoryTappedBlock)(MKAnnotationView *annotationView, UIControl *accessoryControl);

@interface DistrictPinAnnotationView : MKPinAnnotationView {
}
+ (DistrictPinAnnotationView*)districtPinViewWithAnnotation:(id<MKAnnotation>)annotation identifier:(NSString *)reuseIdentifier;
- (void)setPinColorWithAnnotation:(id <MKAnnotation>)anAnnotation;
- (void)enableAccessoryWithOnAccessoryTappedBlock:(AnnotationOnAccessoryTappedBlock)block;
- (void)enableAccessory;
- (void)disableAccessory;
@property (nonatomic,retain) UIButton *accessory;
@end
    
extern NSString* const DistrictPinAnnotationViewReuseIdentifier;
