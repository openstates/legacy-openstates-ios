//
//  PolygonMath.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef struct {
	double x,y;
} MapPoint;

@interface PolygonMath : NSObject {
	
}
+ (BOOL) insidePolygon:(CLLocationCoordinate2D *)polygon count:(NSInteger)N point:(CLLocationCoordinate2D) p;
+ (BOOL) pnpoly:(double *)xp yp:(double *)yp count:(NSInteger)npol x:(double)x y:(double)y;



@end
