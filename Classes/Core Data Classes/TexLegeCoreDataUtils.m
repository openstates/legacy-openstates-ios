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
	NSArray *objects = [TexLegeCoreDataUtils allObjectsInEntityNamed:entityName context:context];
	if (!objects || ![objects count])
		return nil;
	NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[objects count]];
	for (NSManagedObject *object in objects) {
		[objectIDs addObject:[object objectID]];
	}
	
	return objectIDs;
	
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
