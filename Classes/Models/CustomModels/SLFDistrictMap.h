#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "_SLFDistrictMap.h"

@interface SLFDistrictMap : _SLFDistrictMap <MKAnnotation> {}

@property (nonatomic,assign) MKCoordinateRegion region;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;

- (MKPolygon *)polygonFactory;
@property (nonatomic,retain) MKPolygon *districtPolygon;

@end
