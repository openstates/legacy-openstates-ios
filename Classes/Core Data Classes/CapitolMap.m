//
//  CapitolMap.m
//  TexLege
//
//  Created by Gregory Combs on 7/11/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CapitolMap.h"


@implementation CapitolMap
@synthesize name = m_name, file = m_file, type = m_type, order = m_order;

- (void)dealloc {
	self.name = nil;
	self.file = nil;
	self.type = nil;
	self.order = nil;
	[super dealloc];
}

- (void) importFromDictionary: (NSDictionary *)dictionary
{				
	if (dictionary) {
		self.name = [dictionary objectForKey:@"name"];
		self.file = [dictionary objectForKey:@"file"];
		self.type = [dictionary objectForKey:@"type"];
		self.order = [dictionary objectForKey:@"order"];
	}
}


- (NSDictionary *)exportToDictionary {
	NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.name, @"name",
							  self.file, @"file",
							  self.type, @"type",
							  self.order, @"order",
							  nil];
	return tempDict;
}
/*
- (id)proxyForJson {
    return [self exportToDictionary];
}
*/

- (NSURL *)url {
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *filePath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, self.file ];
	
	return [NSURL fileURLWithPath:filePath];
	
}

@end
