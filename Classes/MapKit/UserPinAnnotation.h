//
//  CustomAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SVPlacemark.h"

#define kUserPinAnnotationAddressChangeKey @"UserPinAnnotationAddressChangeNotification"
@interface UserPinAnnotation : SVPlacemark <MKAnnotation> {
}

@property (nonatomic, copy)		NSNumber				*pinColorIndex;
@property (nonatomic, copy)		NSString				*title;
@property (nonatomic, copy)		NSString				*subtitle;
@property (nonatomic, copy)		NSString				*imageName;

@property (nonatomic, retain) id	coordinateChangedDelegate;

-(id)initWithSVPlacemark:(SVPlacemark*)placemark;

- (UIImage *)image;

@end
