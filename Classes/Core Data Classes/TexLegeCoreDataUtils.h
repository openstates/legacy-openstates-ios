//
//  TexLegeCoreDataUtils.h
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LegislatorObj, CommitteeObj;
@interface TexLegeCoreDataUtils : NSObject {

}

+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName context:(NSManagedObjectContext*)context;
+ (LegislatorObj*)legislatorForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber withContext:(NSManagedObjectContext*)context;
+ (LegislatorObj*)legislatorWithLegislatorID:(NSNumber*)legID withContext:(NSManagedObjectContext*)context;
+ (CommitteeObj*)committeeWithCommitteeID:(NSNumber*)comID withContext:(NSManagedObjectContext*)context;

+ (NSArray *) allLegislatorsSortedByPartisanshipFromChamber:(NSInteger)chamber andPartyID:(NSInteger)party context:(NSManagedObjectContext *)context;
+ (NSArray *) allDistrictMapsLightWithContext:(NSManagedObjectContext*)context;

+ (NSArray*)allObjectIDsInEntityNamed:(NSString*)entityName context:(NSManagedObjectContext*)context;
+ (NSArray*)allObjectsInEntityNamed:(NSString*)entityName context:(NSManagedObjectContext*)context;

+ (void) deleteAllObjectsInEntityNamed:(NSString*)entityName context:(NSManagedObjectContext*)context;

@end

@interface NSManagedObjectContext (EZFetch)


// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...;
@end