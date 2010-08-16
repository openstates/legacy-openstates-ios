//
//  MapViewController.h
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, MKReverseGeocoderDelegate> {
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UISegmentedControl *mapTypeControl;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *bookmarksButton;

@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;

- (IBAction)changeMapType:(id)sender;
- (IBAction)locateUser:(id)sender;

- (IBAction)reverseGeocodeCurrentLocation;
@end
