//
//  MapViewController.h
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SVGeocoder.h"
#import "SVPlacemark.h"
#import "DistrictMapSearchOperation.h"

@class DistrictMapDataSource, UserPinAnnotation;
@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate,
		SVGeocoderDelegate, UISplitViewControllerDelegate, UIActionSheetDelegate,
		UIGestureRecognizerDelegate, DistrictMapSearchOperationDelegate> {
}

@property (nonatomic,retain) IBOutlet UIPopoverController *masterPopover;
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UISegmentedControl *mapTypeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *mapTypeControlButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *districtOfficesButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *searchBarButton;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) SVGeocoder *geocoder;
@property (nonatomic,readonly) MKCoordinateRegion texasRegion;
@property (nonatomic,retain) UserPinAnnotation *searchLocation;
@property (nonatomic,assign) MKPolygonView *senateDistrictView, *houseDistrictView;
@property (nonatomic,retain) NSOperationQueue *genericOperationQueue;

- (IBAction) showAllDistricts:(id)sender;
//- (IBAction) showAllDistrictOffices:(id)sender;
- (IBAction) changeMapType:(id)sender;
- (IBAction) locateUser:(id)sender;
- (void) clearAnnotationsAndOverlays;
- (void) clearAnnotationsAndOverlaysExceptRecent;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void) moveMapToAnnotation:(id<MKAnnotation>)annotation;
- (void) searchDistrictMapsForCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
