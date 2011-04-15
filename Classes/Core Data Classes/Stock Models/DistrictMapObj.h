//
//  DistrictMapObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class LegislatorObj;

@interface DistrictMapObj :  RKManagedObject  <MKAnnotation> // NSCoding
{
}

@property (nonatomic, retain) NSNumber * chamber;
@property (nonatomic, retain) NSNumber * centerLon;
@property (nonatomic, retain) NSNumber * spanLat;
@property (nonatomic, retain) NSNumber * districtMapID;
@property (nonatomic, retain) NSNumber * lineWidth;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSData * coordinatesData;
@property (nonatomic, retain) NSNumber * pinColorIndex;
@property (nonatomic, retain) NSNumber * numberOfCoords;
@property (nonatomic, retain) NSNumber * maxLat;
@property (nonatomic, retain) NSNumber * minLat;
@property (nonatomic, retain) NSNumber * spanLon;
@property (nonatomic, retain) NSString * coordinatesBase64;
@property (nonatomic, retain) NSNumber * maxLon;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) id lineColor;
@property (nonatomic, retain) NSNumber * minLon;
@property (nonatomic, retain) NSNumber * centerLat;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



