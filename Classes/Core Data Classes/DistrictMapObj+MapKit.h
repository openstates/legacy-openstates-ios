//
//  DistrictMapObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictMapObj.h"

@interface DistrictMapObj (MapKit)
{
}

@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) MKCoordinateRegion		region;
@property (nonatomic, readonly) MKCoordinateSpan		span;

- (UIImage *)image;
- (MKPolyline *)polyline;
- (MKPolygon *)polygon;
- (BOOL) districtContainsCoordinate:(CLLocationCoordinate2D)aCoordinate;
@end



