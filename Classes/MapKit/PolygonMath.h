//
//  PolygonMath.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	double x,y;
} MapPoint;

@interface PolygonMath : NSObject {
	
}
- (BOOL) insidePolygon:(MapPoint *)polygon count:(NSInteger)N point:(MapPoint) p;



@end
