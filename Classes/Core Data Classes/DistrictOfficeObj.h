//
//  DistrictOfficeObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class DistrictMapObj;
@class LegislatorObj;

@interface DistrictOfficeObj :  RKManagedObject  <MKAnnotation>
{
	NSNumber * districtOfficeID;
	NSNumber * chamber;
	NSNumber * spanLat;
	NSNumber * pinColorIndex;
	NSNumber * longitude;
	NSString * stateCode;
	NSNumber * latitude;
	NSString * formattedAddress;
	NSString * address;
	NSString * city;
	NSString * county;
	NSString * phone;
	NSString * fax;
	NSNumber * district;
	NSNumber * spanLon;
	NSString * zipCode;
	NSNumber * legislatorID;
	NSString * updated;
	LegislatorObj * legislator;	
}

@property (nonatomic, retain) NSNumber * districtOfficeID;
@property (nonatomic, retain) NSNumber * chamber;
@property (nonatomic, retain) NSNumber * spanLat;
@property (nonatomic, retain) NSNumber * pinColorIndex;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * stateCode;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * county;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) NSNumber * spanLon;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) LegislatorObj * legislator;
@property (nonatomic, retain) NSString * updated;

// MKAnnotation protocol
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) MKCoordinateRegion		region;
@property (nonatomic, readonly) MKCoordinateSpan		span;

- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;

- (NSString *)cellAddress;
@end



