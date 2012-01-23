#import "MultiRowAnnotationProtocol.h"
#import "_SLFDistrict.h"

@class RKManagedObjectMapping;
@class SLFChamber;
@class SLFParty;
@interface SLFDistrict : _SLFDistrict <MultiRowAnnotationProtocol> {}
@property (nonatomic,readonly) SLFChamber *chamberObj;
@property (nonatomic,readonly) BOOL isUpperChamber;
@property (nonatomic,assign) MKCoordinateRegion region;
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,readonly) SLFParty *party;
@property (nonatomic,retain) MKPolygon *districtPolygon;
@property (nonatomic,readonly) NSUInteger pinColorIndex;
@property (nonatomic,readonly,copy) NSString *title;
@property (nonatomic,readonly,copy) NSString *subtitle;
- (NSArray *)calloutCells;
- (UIImage *)image;
- (MKPolygon *)polygonFactory;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSArray *)sortDescriptors;
+ (NSString *)estimatedBoundaryIDForDistrict:(NSString *)district chamber:(SLFChamber *)chamber;
@end
