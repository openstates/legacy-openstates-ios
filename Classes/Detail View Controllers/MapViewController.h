//
//  MapViewController.h
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"
#import "SynthesizeSingleton.h"

@class DistrictOfficeObj;
@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate,
		MKReverseGeocoderDelegate, BSForwardGeocoderDelegate, UISplitViewControllerDelegate, UIActionSheetDelegate> {
}
+ (MapViewController *)sharedMapViewController;

@property (nonatomic,retain) IBOutlet UIPopoverController *popoverController;
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UISegmentedControl *mapTypeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *mapTypeControlButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *bookmarksButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *districtOfficesButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *mapControlsButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *searchBarButton;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic,retain) BSForwardGeocoder *forwardGeocoder;
@property (nonatomic,readonly) MKCoordinateRegion texasRegion;

- (IBAction) mapControlSheet:(id)sender;
- (IBAction) showAllDistrictMaps:(id)sender;
- (IBAction) showAllDistrictOffices:(id)sender;
- (IBAction) changeMapType:(id)sender;
- (IBAction) locateUser:(id)sender;
- (IBAction) reverseGeocodeCurrentLocation;
- (void) clearAnnotationsAndOverlays;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation;

	
//- (NSString *)popoverButtonTitle;

@end
