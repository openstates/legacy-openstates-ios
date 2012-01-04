//
//  UserPinAnnotation.h
//  Created by Gregory Combs on 7/27/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
