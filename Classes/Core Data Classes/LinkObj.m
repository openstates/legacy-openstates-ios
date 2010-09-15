// 
//  LinkObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LinkObj.h"


@implementation LinkObj

@dynamic order;
@dynamic url;
@dynamic label;
@dynamic timeStamp;
@dynamic section;

- (void) importFromDictionary: (NSDictionary *)dictionary
{				
	if (dictionary) {
		self.order = [dictionary objectForKey:@"order"];
		self.url = [dictionary objectForKey:@"url"];
		self.label = [dictionary objectForKey:@"label"];
		self.timeStamp = [dictionary objectForKey:@"timeStamp"];
		self.section = [dictionary objectForKey:@"section"];
	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.order, @"order",
							  self.url, @"url",
							  self.label, @"label",
							  self.timeStamp, @"timeStamp",
							  self.section, @"section",
							  nil];
	return tempDict;
}


@end
