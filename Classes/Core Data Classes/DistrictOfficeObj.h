//
//  DistrictOfficeObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class DistrictMapObj;
@class LegislatorObj;

@interface DistrictOfficeObj :  NSManagedObject  <NSCoding, MKAnnotation>
{
}

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
@property (nonatomic, retain) LegislatorObj * legislator;
@property (nonatomic, retain) DistrictMapObj * districtMap;

// MKAnnotation protocol
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) MKCoordinateRegion		region;
@property (nonatomic, readonly) MKCoordinateSpan		span;

- (NSString *)title;
- (NSString *)subtitle;
- (UIImage *)image;

- (NSString *)cellAddress;

- (id) initWithDictionary: (NSDictionary *)dictionary;
- (NSDictionary *)exportDictionary;
@end



