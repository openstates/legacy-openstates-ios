//
//  CustomAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


#define kCustomAnnotationAddressChangeNotificationKey @"CustomAnnotationAddressChangeNotification"
@class BSKmlResult;
@interface CustomAnnotation : NSObject <MKAnnotation, NSCoding> {
}

@property (nonatomic, copy)		NSNumber				*pinColorIndex;
@property (nonatomic, copy)		NSDictionary			*regionDict;
@property (nonatomic, copy)		NSDictionary			*addressDict;
@property (nonatomic, copy)		NSString				*title;
@property (nonatomic, copy)		NSString				*subtitle;
@property (nonatomic, copy)		NSString				*imageName;

@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) MKCoordinateRegion		region;
@property (nonatomic, readonly) MKCoordinateSpan		span;
@property (nonatomic, retain) id	coordinateChangedDelegate;

-(id)initWithBSKmlResult:(BSKmlResult*)kmlResult;
-(id)initWithRegion:(MKCoordinateRegion) newRegion;

- (UIImage *)image;

- (void)setAddressDictWithPlacemark:(MKPlacemark *)placemark;

@end
