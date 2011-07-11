//
//  MapMiniDetailViewController.h
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
@interface MapMiniDetailViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,readonly) MKCoordinateRegion texasRegion;
@property (nonatomic,assign) MKPolygonView *districtView;
@property (nonatomic) CLLocationCoordinate2D annotationActionCoord;

- (void) clearAnnotationsAndOverlays;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void) moveMapToAnnotation:(id<MKAnnotation>)annotation;

@end
