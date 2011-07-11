//
//  MultiPolyline.h
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

#import <MapKit/MapKit.h>


@interface MultiPolyline : NSObject <MKOverlay> {
    NSArray *_polylines;
    MKMapRect _boundingMapRect;
}

- (id)initWithPolylines:(NSArray *)polylines;
@property (nonatomic, readonly) NSArray *polylines;

@end