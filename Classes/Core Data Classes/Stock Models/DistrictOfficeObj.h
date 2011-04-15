//
//  DistrictOfficeObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class LegislatorObj;

@interface DistrictOfficeObj :  RKManagedObject  <MKAnnotation>
{
}

@property (nonatomic, retain) NSNumber * chamber;
@property (nonatomic, retain) NSNumber * spanLat;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * districtOfficeID;
@property (nonatomic, retain) NSNumber * pinColorIndex;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * stateCode;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * county;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) NSNumber * spanLon;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



