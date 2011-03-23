//
//  TexLegeObjectCache.m
//  TexLege
//
//  Created by Gregory Combs on 3/21/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "TexLegeObjectCache.h"

#import "LegislatorObj.h"
#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "DistrictMapObj.h"
#import "DistrictOfficeObj.h"
#import "StafferObj.h"
#import "WnomObj.h"
#import "LinkObj.h"
#import "NSDate+Helper.h"
#import "UtilityMethods.h"

@implementation TexLegeObjectCache


- (NSArray*)fetchRequestsForResourcePath:(NSString*)resourcePath {
	
	//BOOL onlyID = NO;
	if (YES == [resourcePath hasPrefix:@"/rest_ids.php"]) {	//??????
		//resourcePath = [resourcePath substringFromIndex:[@"/rest_ids.php/" length]];
		//onlyID = YES;
		return nil;			/// ???????????
	}
	else
		resourcePath = [resourcePath substringFromIndex:[@"/rest.php/" length]];		
					
	NSArray* components = [resourcePath componentsSeparatedByString:@"/"];
	NSInteger count = [components count];
	NSString *modelString = [components objectAtIndex:0];
	Class modelClass = NSClassFromString(modelString);
	if (!modelClass)
		return nil;
	
	NSString *primaryKey = [modelClass primaryKeyProperty];

	if (count > 1) {
		NSString *params = [components objectAtIndex:1];
		if ([params hasPrefix:@"?"]) {
			NSDictionary *paramsDict = [UtilityMethods parametersOfQuery:[params substringFromIndex:1]];	// chop off the ?

			if ([[paramsDict allKeys] containsObject:@"updated_since"]) {
				NSString* updatedString = [[paramsDict objectForKey:@"updated_since"] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
				NSDate *updatedDate = [NSDate dateFromString:updatedString];
				NSFetchRequest* request = [modelClass fetchRequest];
				NSPredicate* predicate = [NSPredicate predicateWithFormat:@"updated >= %@", updatedDate, nil];
				[request setPredicate:predicate];
				NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES];
				[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
				return [NSArray arrayWithObject:request];
			}
		}
		else {
			NSNumber* ID = [NSNumber numberWithInt:[params intValue]];
			NSFetchRequest* request = [modelClass fetchRequest];
			NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%@ = %@", primaryKey, ID, nil];
			[request setPredicate:predicate];
			NSSortDescriptor *one = [NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES] ;
			[request setSortDescriptors:[NSArray arrayWithObjects:one, nil]];
			return [NSArray arrayWithObject:request];
			
		}

	}	
	return nil;
}

@end
