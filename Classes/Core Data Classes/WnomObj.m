// 
//  WnomObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "WnomObj.h"

#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"

@implementation WnomObj 

@dynamic wnomAdj;
@dynamic session;
@dynamic wnomStderr;
@dynamic legislator;
@dynamic adjMean;

- (void) importFromDictionary: (NSDictionary *)dictionary
{
	if (dictionary) {
		self.wnomAdj = [dictionary objectForKey:@"wnomAdj"];
		self.session = [dictionary objectForKey:@"session"];
		self.wnomStderr = [dictionary objectForKey:@"wnomStderr"];
		self.adjMean = [dictionary objectForKey:@"adjMean"];
		
		NSNumber *legislatorID = [dictionary objectForKey:@"legislatorID"];
		if (legislatorID)
			self.legislator = [TexLegeCoreDataUtils legislatorWithLegislatorID:legislatorID withContext:[self managedObjectContext]];
	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.wnomAdj, @"wnomAdj",
							  self.session, @"session",
							  self.wnomStderr, @"wnomStderr",
							  self.adjMean, @"adjMean",
							  self.legislator.legislatorID, @"legislatorID",
							  nil];
	return tempDict;
}

- (id)proxyForJson {
    return [self exportToDictionary];
}

- (NSNumber *) year {
	return [NSNumber numberWithInteger:1847+(2*[self.session integerValue])];
}


@end
