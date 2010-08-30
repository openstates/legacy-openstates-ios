//
//  MultiPolylineView.m
//  TexLege
//
//  Created by Gregory Combs on 8/25/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
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