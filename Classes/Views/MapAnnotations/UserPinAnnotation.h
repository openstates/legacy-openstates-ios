//
//  UserPinAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <MapKit/MapKit.h>
#import "SVPlacemark.h"

#define kUserPinAnnotationAddressChangeKey @"UserPinAnnotationAddressChangeNotification"

@interface UserPinAnnotation : SVPlacemark <MKAnnotation> {
}

@property (nonatomic, copy) NSNumber *pinColorIndex;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, retain) id coordinateChangedDelegate;
-(id)initWithSVPlacemark:(SVPlacemark*)placemark;
- (UIImage *)image;
@end
