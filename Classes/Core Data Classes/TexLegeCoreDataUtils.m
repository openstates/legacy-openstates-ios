//
//  TexLegeCoreDataUtils.m
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeCoreDataUtils.h"
#import "LegislatorObj.h"
#import "CommitteeObj.h"
#import "DistrictMapObj.h"
#import "DistrictOfficeObj.h"


@implementation NSManagedObjectContext (EZFetch)


// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
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
	[request release];
	
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return [NSSet setWithArray:results];
}

- (NSArray *)fetchObjectIDsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ... 
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
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
		[request setResultType:NSManagedObjectIDResultType];	// only return object IDs
		
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
	[request release];
	
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return results;
}

@end

@implementation TexLegeCoreDataUtils

+ (void)saveWithContext:(NSManagedObjectContext *)context{
	@try {
		NSError *error;
		if (![context save:&error]) {
			debug_NSLog(@"Failure in TexLegeCoreDataUtils:save - unresolved error %@, %@", error, [error userInfo]);
		}		
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in TexLegeCoreDataUtils:save, name=%@ reason=%@", e.name, e.reason);
	}
}

+ (DistrictMapObj*)districtMapForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber withContext:(NSManagedObjectContext*)context {
	return [TexLegeCoreDataUtils districtMapForDistrict:district andChamber:chamber withContext:context lightProperties:NO];
}

+ (DistrictMapObj*)districtMapForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber withContext:(NSManagedObjectContext*)context lightProperties:(BOOL)light {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.chamber == %@", district, chamber];
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"DistrictMapObj" context:context lightProperties:light];
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

+ (CommitteeObj*)committeeWithCommitteeID:(NSNumber*)comID withContext:(NSManagedObjectContext*)context
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.committeeId == %@", comID];
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"CommitteeObj" context:context];
}


+ (NSArray *) allLegislatorsSortedByPartisanshipFromChamber:(NSInteger)chamber andPartyID:(NSInteger)party context:(NSManagedObjectContext *)context
{
	if (chamber == BOTH_CHAMBERS) {
		debug_NSLog(@"allMembersByChamber: ... cannot be BOTH chambers");
		return nil;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSString *predicateString = nil;
	if (party > kUnknownParty)
//		predicateString = [NSString stringWithFormat:@"legtype == %d AND party_id == %d AND partisan_index <> 0.0", chamber, party];
		predicateString = [NSString stringWithFormat:@"legtype == %d AND party_id == %d", chamber, party];
	else
		//predicateString = [NSString stringWithFormat:@"legtype == %d AND partisan_index <> 0.0", chamber];
		predicateString = [NSString stringWithFormat:@"legtype == %d", chamber];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString]; 
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"partisan_index" ascending:(party != REPUBLICAN)];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	//if (error)
	//	debug_NSLog(@"allMembersByChamber:andParty: error in executeFetchRequest: %@, %@", error, [error userInfo]);
	
	return fetchedObjects;
	
}

+ (NSArray *) allStaffersForLegislator:(NSNumber *)legislatorID context:(NSManagedObjectContext *)context
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"StafferObj" 
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSString *predicateString = [NSString stringWithFormat:@"legislatorID == %@", legislatorID];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString]; 
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"title" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	return fetchedObjects;
	
}

+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName context:(NSManagedObjectContext*)context {
	return [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:entityName context:context lightProperties:NO];
}


// You better make the predicate specific ... so that it only provides one result.  
+ (id)dataObjectWithPredicate:(NSPredicate *)predicate entityName:(NSString*)entityName context:(NSManagedObjectContext*)context lightProperties:(BOOL)light {
	if (!context || !predicate || !entityName)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	
	if (light && [entityName isEqualToString:@"DistrictMapObj"])
		[request setPropertiesToFetch:[DistrictMapObj lightPropertiesToFetch]];

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

+ (NSArray *)allDistrictMapIDsWithBoundingBoxesContaining:(CLLocationCoordinate2D)coordinate withContext:(NSManagedObjectContext*)context 
{	
	if (!context)
		return nil;
	
	NSArray *fetchedObjects = nil;
	NSNumber *lat = [NSNumber numberWithDouble:coordinate.latitude];
	NSNumber *lon = [NSNumber numberWithDouble:coordinate.longitude];
	
	NSString *predicateString = [NSString stringWithFormat:@"maxLat >= %@ AND minLat <= %@ AND maxLon >=%@ AND minLon <= %@", lat, lat, lon, lon];	
	
	// i tried to put this in a try/catch but the compiler wouldn't take it.
	fetchedObjects = [context fetchObjectIDsForEntityName:@"DistrictMapObj" withPredicate:predicateString];

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
	/*NSUndoManager *undomgr = [context undoManager];
	[context setUndoManager:nil];
	[TexLegeCoreDataUtils saveWithContext:context];
	[context setUndoManager:undomgr];*/
}



@end

