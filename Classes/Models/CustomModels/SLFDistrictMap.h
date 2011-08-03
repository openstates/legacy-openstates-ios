#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "_SLFDistrictMap.h"

@interface SLFDistrictMap : _SLFDistrictMap <MKAnnotation> {}

- (CLLocationCoordinate2D)centroid;
- (CLLocationCoordinate2D)coordinate;
- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;

- (MKPolygon *)polygonAndRegion:(MKCoordinateRegion *)regionRef;

@property (nonatomic,retain) MKPolygon *districtPolygon;
@property (nonatomic,assign) MKCoordinateRegion region;
@end
