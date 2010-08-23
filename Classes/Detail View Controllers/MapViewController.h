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

@class DistrictOfficeObj;
@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate,
		MKReverseGeocoderDelegate, BSForwardGeocoderDelegate, UISplitViewControllerDelegate> {
}

@property (nonatomic,retain) IBOutlet UIPopoverController *popoverController;
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UISegmentedControl *mapTypeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *bookmarksButton;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic,retain) BSForwardGeocoder *forwardGeocoder;
@property (nonatomic,copy) NSString *addressString;
@property (nonatomic,readonly) MKCoordinateRegion texasRegion;
@property (nonatomic) BOOL shouldAnimate;

- (IBAction) showAllDistrictOffices:(id)sender;
- (IBAction)changeMapType:(id)sender;
- (IBAction)locateUser:(id)sender;
- (IBAction)reverseGeocodeCurrentLocation;
- (void)setAddressString:(NSString *)string;

//- (NSString *)popoverButtonTitle;

@end
