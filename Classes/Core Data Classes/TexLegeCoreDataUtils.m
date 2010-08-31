//
//  TexLegeCoreDataUtils.m
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeCoreDataUtils.h"
#import "LegislatorObj.h"

@implementation TexLegeCoreDataUtils

+ (LegislatorObj*)legislatorForDistrict:(NSNumber*)district andChamber:(NSNumber*)chamber withContext:(NSManagedObjectContext*)context;
{
	if (!context)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.district == %@ AND self.legtype == %@", district, chamber];
	[request setPredicate:predicate];
	
	LegislatorObj *foundObject = nil;
	
	NSError *error = nil;
	NSArray *lege_array = [context executeFetchRequest:request error:&error];
	if (lege_array != nil) {
		if ([lege_array count] > 0) { // may be 0 if the object has been deleted
			foundObject = [lege_array objectAtIndex:0]; // just get the first (only!!) one.
		}
	}
	if (!foundObject) {
		debug_NSLog(@"No Legislator Found for chamber=%@ district=%@", chamber, district); 
	}
	
	[request release];
	return foundObject;
}

+ (LegislatorObj*)legislatorWithLegislatorID:(NSNumber*)legID withContext:(NSManagedObjectContext*)context;
{
	if (!context)
		return nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LegislatorObj" 
											  inManagedObjectContext:context];
	[request setEntity:entity];
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.legislatorID == %@", legID];
	[request setPredicate:predicate];
	
	LegislatorObj *foundObject = nil;
	
	NSError *error = nil;
	NSArray *lege_array = [context executeFetchRequest:request error:&error];
	if (lege_array != nil) {
		if ([lege_array count] > 0) { // may be 0 if the object has been deleted
			foundObject = [lege_array objectAtIndex:0]; // just get the first (only!!) one.
		}
	}
	if (!foundObject) {
		debug_NSLog(@"No Legislator Found with ID=%@", legID); 
	}
	
	[request release];
	return foundObject;
}


@end
