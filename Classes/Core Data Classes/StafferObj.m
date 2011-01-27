// 
//  StafferObj.m
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "StafferObj.h"
#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"

@implementation StafferObj 

@dynamic phone;
@dynamic title;
@dynamic email;
@dynamic name;
@dynamic stafferID;
@dynamic legislator;
@dynamic legislatorID;


- (void) importFromDictionary: (NSDictionary *)dictionary
{
	if (dictionary) {
		self.phone = [dictionary objectForKey:@"phone"];
		self.title = [dictionary objectForKey:@"title"];
		self.email = [dictionary objectForKey:@"email"];
		self.name = [dictionary objectForKey:@"name"];
		self.stafferID = [dictionary objectForKey:@"stafferID"];
		
		NSNumber *legislatorID = [dictionary objectForKey:@"legislatorID"];
		if (legislatorID)
			self.legislator = [TexLegeCoreDataUtils legislatorWithLegislatorID:legislatorID withContext:[self managedObjectContext]];
	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.phone, @"phone",
							  self.title, @"title",
							  self.email, @"email",
							  self.name, @"name",
							  self.stafferID, @"stafferID",
							  self.legislator.legislatorID, @"legislatorID",
							  nil];
	return tempDict;
}

- (id)proxyForJson {
    return [self exportToDictionary];
}

@end
