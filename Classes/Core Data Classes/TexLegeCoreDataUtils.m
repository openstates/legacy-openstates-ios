//
//  TexLegeCoreDataUtils.m
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeCoreDataUtils.h"
#import "LegislatorObj.h"
#import "DistrictMapObj.h"
#import "DistrictOfficeObj.h"


@implementation TexLegeCoreDataUtils

+ (void)saveWithContext:(NSManagedObjectContext *)context{
	@try {
		NSError *error;
		if (![context save:&error]) {
			debug_NSLog(@"DirectoryDataSource:save - unresolved error %@, %@", error, [error userInfo]);
		}		
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in DirectoryDataSource:save, name=%@ reason=%@", e.name, e.reason);
	}
}

+ (LegislatorObj*)legislatorForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber withContext:(NSManagedObjectContext*)context
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.legtype == %@", district, chamber];
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"LegislatorObj" context:context];
}

+ (LegislatorObj*)legislatorWithLegislatorID:(NSNumber*)legID withContext:(NSManagedObjectContext*)context
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.legislatorID == %@", legID];
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"LegislatorObj" context:context];
}

// You better make the predicate specific ... so that it only provides one result.  
+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName context:(NSManagedObjectContext*)context
{
	if (!context || !predicate || !entityName)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	
	
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.legtype == %@", district, chamber];
	[request setPredicate:predicate];
	
	NSManagedObject *foundObject = nil;
	
	NSError *error = nil;
	NSArray *objArray = [context executeFetchRequest:request error:&error];
	if (objArray != nil) {
		if ([objArray count] > 0) { // may be 0 if the object has been deleted
			foundObject = [objArray objectAtIndex:0]; // just get the first (only!!) one.
		}
	}
	if (!foundObject) {
		debug_NSLog(@"No object found for predicate=%@", predicate); 
	}
	
	[request release];
	return foundObject;
}

+ (NSArray*)allObjectsInEntityNamed:(NSString*)entityName context:(NSManagedObjectContext*)context {
	if (!context || !entityName)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.legtype == %@", district, chamber];
	//[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *objArray = [context executeFetchRequest:request error:&error];
	if (!objArray || error) {
		debug_NSLog(@"Error while obtaining objects for entity=%@ error=%@", entityName, error); 
	}
	
	[request release];
	return objArray;
	
}

+ (NSArray*)allObjectIDsInEntityNamed:(NSString*)entityName context:(NSManagedObjectContext*)context {
	if (!context || !entityName)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	[request setResultType:NSManagedObjectIDResultType];	// only return object IDs
	
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.legtype == %@", district, chamber];
	//[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *objArray = [context executeFetchRequest:request error:&error];
	if (!objArray || error) {
		debug_NSLog(@"Error while obtaining objects for entity=%@ error=%@", entityName, error); 
	}
	
	[request release];
	return objArray;
}


+ (NSArray *) allDistrictMapsLightWithContext:(NSManagedObjectContext*)context {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictMapObj" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setPropertiesToFetch:[DistrictMapObj lightPropertiesToFetch]];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (error) {
		debug_NSLog(@"Problem fetching district maps.");
		return nil;
	}
		
	return fetchedObjects;
}


/*
- (NSArray *) allDistrictMapsFetchingBoundingBoxes {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = self.managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictMapObj" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"minLat", @"maxLat", @"minLon", @"maxLon", nil]];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (error) {
		debug_NSLog(@"Problem fetching district maps.");
		return nil;
	}
	
	NSMutableArray *districts = [[[NSMutableArray alloc] initWithCapacity:181] autorelease];
	for (DistrictMapObj *map in fetchedObjects) {
		if ([map districtContainsCoordinate:aCoordinate])
			[districts addObject:map];
	}
	
	//[self.mapView removeOverlays:[self.mapView overlays]];
	
	//[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3f];
	//self.shouldAnimate = NO;
	//[self.mapView addOverlays:array];	
	
	return districts;
	
}
*/

+ (void) deleteAllObjectsInEntityNamed:(NSString*)entityName context:(NSManagedObjectContext*)context {
	debug_NSLog(@"I HOPE YOU REALLY WANT TO DO THIS ... DELETING ALL OBJECTS IN %@", entityName);
	debug_NSLog(@"----------------------------------------------------------------------");
	
	if (!context || !entityName)
		return;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		debug_NSLog(@"There's no objects to delete ???");
	}
	[fetchRequest release];
	
	for (NSManagedObject *object in fetchedObjects) {
		[context deleteObject:object];
	}
	[TexLegeCoreDataUtils saveWithContext:context];
}



@end

@implementation NSManagedObjectContext (EZFetch)


// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate class]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return [NSSet setWithArray:results];
}

@end
