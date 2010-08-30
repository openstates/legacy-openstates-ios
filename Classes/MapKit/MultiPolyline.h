//
//  MultiPolyline.h
//  TexLege
//
//  Created by Gregory Combs on 8/25/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
//	James Howard at Apple came up with this on the Developer Forums
//	https://devforums.apple.com/thread/48154?tstart=0

#import <MapKit/MapKit.h>


@interface MultiPolyline : NSObject <MKOverlay> {
    NSArray *_polylines;
    MKMapRect _boundingMapRect;
}

- (id)initWithPolylines:(NSArray *)polylines;
@property (nonatomic, readonly) NSArray *polylines;

@end