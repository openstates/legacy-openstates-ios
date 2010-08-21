//
//  PolygonMath.m
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "PolygonMath.h"


@implementation PolygonMath

//The following C function returns INSIDE or OUTSIDE indicating the status of a point P with respect to a polygon with N points.

//#define MIN(x,y) (x < y ? x : y)
//#define MAX(x,y) (x > y ? x : y)
#define INSIDE YES
#define OUTSIDE NO

- (BOOL) insidePolygon:(MapPoint *)polygon count:(NSInteger)N point:(MapPoint) p;
{
	debug_NSLog(@"Starting insidePolygon: %@", [NSDate date]);
	
	NSInteger counter = 0;
	NSInteger i = 0;
	double xinters;
	MapPoint p1,p2;
	
	p1 = polygon[0];
	for (i=1;i<=N;i++) {
		p2 = polygon[i % N];
		if (p.y > MIN(p1.y,p2.y)) {
			if (p.y <= MAX(p1.y,p2.y)) {
				if (p.x <= MAX(p1.x,p2.x)) {
					if (p1.y != p2.y) {
						xinters = (p.y-p1.y)*(p2.x-p1.x)/(p2.y-p1.y)+p1.x;
						if (p1.x == p2.x || p.x <= xinters)
							counter++;
					}
				}
			}
		}
		p1 = p2;
	}
	
	debug_NSLog(@"Ending insidePolygon: %@", [NSDate date]);

	if (counter % 2 == 0)
		return(OUTSIDE);
	else
		return(INSIDE);
}

//The following code is by Randolph Franklin, it returns 1 for interior points and 0 for exterior points.
- (BOOL) pnpoly:(double *)xp yp:(double *)yp count:(NSInteger)npol x:(double)x y:(double)y;
{
	debug_NSLog(@"Starting pnpoly: %@", [NSDate date]);

	NSInteger i = 0, j = 0;
	BOOL foundInside = NO;
	for (i = 0, j = npol-1; i < npol; j = i++) {
        if ((((yp[i] <= y) && (y < yp[j])) ||
             ((yp[j] <= y) && (y < yp[i]))) &&
            (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i]))
			foundInside = !foundInside;
	}
	
	debug_NSLog(@"Ending pnpoly: %@", [NSDate date]);

	return foundInside;
}
@end
