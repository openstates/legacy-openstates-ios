#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "_SLFDistrict.h"

@class SLFChamber;
@class SLFParty;
@interface SLFDistrict : _SLFDistrict <MKAnnotation> {}
@property (nonatomic,readonly) SLFChamber *chamberObj;
@property (nonatomic,assign) MKCoordinateRegion region;
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,readonly) SLFParty *party;
@property (nonatomic,retain) MKPolygon *districtPolygon;

- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;
- (NSNumber *)pinColorIndex;
- (MKPolygon *)polygonFactory;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
+ (NSString *)estimatedBoundaryIDForDistrict:(NSString *)district chamber:(SLFChamber *)chamber;
@end
