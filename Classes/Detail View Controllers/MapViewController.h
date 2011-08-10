//
//  MapViewController.h
//  Created by Gregory Combs on 8/16/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>

#import "SVGeocoder.h"
#import "SVPlacemark.h"
#import "DistrictMapSearchOperation.h"

@class SLFDistrictMap;
@class DistrictMapDataSource, UserPinAnnotation;
@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate,
		SVGeocoderDelegate, UISplitViewControllerDelegate, UIActionSheetDelegate,
		UIGestureRecognizerDelegate, DistrictMapSearchOperationDelegate, RKObjectLoaderDelegate> {
}
@property (nonatomic,copy)   NSString               * detailObjectID;
@property (nonatomic,copy)   NSString               * resourcePath;
@property (nonatomic,assign) Class                    resourceClass;

- (void) setDistrictMap:(SLFDistrictMap *)newMap;

@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) SVGeocoder *geocoder;
@property (nonatomic,retain) UserPinAnnotation *searchLocation;
@property (nonatomic,assign) MKPolygonView *senateDistrictView, *houseDistrictView;

@property (nonatomic,retain) DistrictMapSearchOperation *geoLegeSearch;

- (IBAction) showAllDistricts:(id)sender;
//- (IBAction) showAllDistrictOffices:(id)sender;
- (IBAction) changeMapType:(id)sender;
- (IBAction) locateUser:(id)sender;
- (void) clearAnnotationsAndOverlays;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void) moveMapToAnnotation:(id<MKAnnotation>)annotation;
- (void) searchDistrictMapsForCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
