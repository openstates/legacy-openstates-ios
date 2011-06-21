//
//  MapMiniDetailViewController.h
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapMiniDetailViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,readonly) MKCoordinateRegion texasRegion;
@property (nonatomic,assign) MKPolygonView *districtView;
@property (nonatomic) CLLocationCoordinate2D annotationActionCoord;

- (void) clearAnnotationsAndOverlays;
- (void) clearAnnotationsAndOverlaysExceptRecent;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void) moveMapToAnnotation:(id<MKAnnotation>)annotation;

@end
