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

- (id)initWithDictionary:(NSDictionary *)mapDict {
	if (self = [super init]) {
		self.name = [mapDict valueForKey:@"name"];
		self.file = [mapDict valueForKey:@"file"];
		self.type = [mapDict valueForKey:@"type"];
		self.order = [mapDict valueForKey:@"order"];		
	}
	return self;
}

- (NSURL *)url {
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *filePath = [ NSString stringWithFormat:
						 @"%@/%@.app/%@",NSHomeDirectory(),appName, self.file ];
	
	return [NSURL fileURLWithPath:filePath];
	
}

@end
