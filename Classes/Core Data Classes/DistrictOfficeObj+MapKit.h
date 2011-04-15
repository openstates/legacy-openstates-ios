//
//  DistrictOfficeObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>

#import "DistrictOfficeObj.h"

@interface DistrictOfficeObj (MapKit)

// MKAnnotation protocol
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) MKCoordinateRegion		region;
@property (nonatomic, readonly) MKCoordinateSpan		span;

- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;
- (NSString *)cellAddress;
@end



