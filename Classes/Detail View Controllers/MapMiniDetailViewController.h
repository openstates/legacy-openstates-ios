//
//  MapMiniDetailViewController.h
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"

@class CustomAnnotation;
@interface MapMiniDetailViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate,
		MKReverseGeocoderDelegate, BSForwardGeocoderDelegate> {
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UISegmentedControl *mapTypeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *mapTypeControlButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *searchBarButton;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic,retain) BSForwardGeocoder *forwardGeocoder;
@property (nonatomic,readonly) MKCoordinateRegion texasRegion;
@property (nonatomic,retain) CustomAnnotation *searchLocation;
@property (nonatomic,retain) MKPolygonView *districtView;

- (IBAction) changeMapType:(id)sender;
- (IBAction) locateUser:(id)sender;
- (IBAction) reverseGeocodeLocation:(CLLocationCoordinate2D)coordinate;
- (void) clearAnnotationsAndOverlays;
- (void) clearAnnotationsAndOverlaysExceptRecent;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void) moveMapToAnnotation:(id<MKAnnotation>)annotation;

@end
