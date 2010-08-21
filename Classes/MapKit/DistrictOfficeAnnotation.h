//
//  DistrictOfficeAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class LegislatorObj;
@class BSKmlResult;
@interface DistrictOfficeAnnotation : NSObject <MKAnnotation, NSCoding> {
}

// Relationship to other managed objects
@property (nonatomic, retain)	LegislatorObj			*legislator;

//@property (nonatomic, readonly)	DistrictMap				*districtMap;
@property (nonatomic, readonly) NSNumber				*districtNumber;
@property (nonatomic, readonly) NSNumber				*chamber;

@property (nonatomic, copy)		NSNumber				*pinColorIndex;
@property (nonatomic, copy)		NSDictionary			*regionDict;
@property (nonatomic, copy)		NSDictionary			*addressDict;
/*
 addressDict:
	NSString *address;
	NSString *countryNameCode;
	NSString *countryName;
	NSString *subAdministrativeAreaName;
	NSString *localityName;
	NSArray *addressComponents;
*/ 

@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) MKCoordinateRegion		region;
@property (nonatomic, readonly) MKCoordinateSpan		span;


-(id)initWithBSKmlResult:(BSKmlResult*)kmlResult;

- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;
@end
