//
//  MapViewController.h
//  Created by Greg Combs on 10/12/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <MapKit/MapKit.h>
#import "StackableControllerProtocol.h"
#import "UserPinAnnotation.h"
#import "GAITrackedViewController.h"

@interface MapViewController : GAITrackedViewController <MKMapViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, StackableController, UserPinAnnotationDelegate>
@property (nonatomic,strong) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic,strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic,readonly) MKCoordinateRegion mapRegion;
@property (nonatomic, strong) MKAnnotationView *selectedAnnotationView;
- (IBAction)changeMapType:(id)sender;
- (IBAction)locateUser:(id)sender;
- (IBAction)resetMap:(id)sender;
- (void)beginBoundarySearchForCoordininate:(CLLocationCoordinate2D)coordinate; // override as needed
- (void)moveMapToRegion:(MKCoordinateRegion)newRegion;
@end
