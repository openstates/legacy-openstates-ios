//
//  TexLegeCoreDataUtils.h
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#if DEBUG
#define RESTKIT_BASE_URL					@"http://www.texlege.com/jsonDataTest"
#else
#define RESTKIT_BASE_URL					@"http://www.texlege.com/rest"
#endif

@class LegislatorObj, CommitteeObj, DistrictMapObj;
@interface TexLegeCoreDataUtils : NSObject {

}
+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName lightProperties:(BOOL)light;
+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName;
+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName;
+ (LegislatorObj*)legislatorForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber;
+ (DistrictMapObj*)districtMapForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber;
+ (DistrictMapObj*)districtMapForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber lightProperties:(BOOL)light;

+ (NSArray *) allLegislatorsSortedByPartisanshipFromChamber:(NSInteger)chamber andPartyID:(NSInteger)party;
+ (NSArray *) allDistrictMapsLight;
+ (NSArray *)allDistrictMapIDsWithBoundingBoxesContaining:(CLLocationCoordinate2D)coordinate;

+ (void) deleteAllObjectsInEntityNamed:(NSString*)entityName;

+ (void)loadDataFromRest:(NSString *)entityName delegate:(id)delegate;
+ (void)initRestKitObjects:(id)sender;

@end

