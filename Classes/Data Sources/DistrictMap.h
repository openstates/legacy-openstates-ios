#if NEEDS_TO_PARSE_KMLMAPS == 1

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface DistrictMap : NSObject <MKAnnotation, NSCoding>{
	CLLocationCoordinate2D *coordinatesCArray;
	NSNumber				*numberOfCoords;
	NSDictionary			*boundingBox;
	NSData					*coordinatesData;
	NSNumber				*legislatorID;
	NSNumber				*district;
	NSNumber				*chamber;
@private
	UIColor					*lineColor;
	NSNumber				*lineWidth;
	NSDictionary			*regionDict;
}

- (void)setComplete:(BOOL)isComplete;

@property (nonatomic, copy)		NSNumber				*district;
@property (nonatomic, copy)		NSNumber				*chamber;
@property (nonatomic, retain)	UIColor					*lineColor;
@property (nonatomic, copy)		NSNumber				*lineWidth;
@property (nonatomic, copy)		NSDictionary			*boundingBox;
@property (nonatomic, copy)		NSNumber				*legislatorID;
@property (nonatomic, copy)		NSDictionary			*regionDict;
@property (nonatomic, readonly) CLLocationCoordinate2D *coordinatesCArray;
@property (nonatomic, copy)		NSNumber				*numberOfCoords;
@property (nonatomic, readonly) MKPolyline				*districtPolyline;
@property (nonatomic, retain)	NSData					*coordinatesData;
@property (nonatomic, readonly)	NSString				*chamberName;
@property (nonatomic, readonly)	MKCoordinateRegion		region;
@property (nonatomic, readonly) NSArray					*points;
@property (nonatomic, readonly) CLLocationCoordinate2D	center;
@property (nonatomic, readonly) MKCoordinateSpan		span;

// for mkannotation
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;

- (NSString *)title;
- (NSString *)subtitle;

- (void)setCoordinatesCArrayWithDictArray:(NSArray *)dictArray;

@end
#endif