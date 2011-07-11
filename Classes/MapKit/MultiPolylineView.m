//
//  MultiPolylineView.m
//  Created by Gregory Combs on 8/25/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//
//	James Howard at Apple came up with this on the Developer Forums
//	https://devforums.apple.com/thread/48154?tstart=0

#import "MultiPolyline.h"
#import "MultiPolylineView.h"


@implementation MultiPolylineView

- (CGPathRef)polyPath:(MKPolyline *)polyline
{
    MKMapPoint *points = [polyline points];
    NSUInteger pointCount = [polyline pointCount];
    NSUInteger i;
	
    if (pointCount < 3)
        return NULL;
	
    CGMutablePathRef path = CGPathCreateMutable();
	
/*
    for (MKPolygon *interiorPolygon in polygon.interiorPolygons) {
        CGPathRef interiorPath = [self polyPath:interiorPolygon];
        CGPathAddPath(path, NULL, interiorPath);
        CGPathRelease(interiorPath);
    }
*/	
    CGPoint relativePoint = [self pointForMapPoint:points[0]];
    CGPathMoveToPoint(path, NULL, relativePoint.x, relativePoint.y);
    for (i = 1; i < pointCount; i++) {
        relativePoint = [self pointForMapPoint:points[i]];
        CGPathAddLineToPoint(path, NULL, relativePoint.x, relativePoint.y);
    }
	
    return path;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    MultiPolyline *multiPolyline = (MultiPolyline *)self.overlay;
    for (MKPolyline *polyline in multiPolyline.polylines) {
        CGPathRef path = [self polyPath:polyline];
        if (path) {
            [self applyFillPropertiesToContext:context atZoomScale:zoomScale];
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextDrawPath(context, kCGPathEOFill);
            [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGPathRelease(path);
        }
    }
}

@end