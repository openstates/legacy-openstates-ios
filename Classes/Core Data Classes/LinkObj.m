// 
//  LinkObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LinkObj.h"
#import "UtilityMethods.h"

@implementation LinkObj

@dynamic order;
@dynamic url;
@dynamic label;
@dynamic section;

- (void) importFromDictionary: (NSDictionary *)dictionary
{				
	if (dictionary)
		[self setValuesForKeysWithDictionary:dictionary];
}


- (NSDictionary *)exportToDictionary {
	NSArray *keys = [NSArray arrayWithObjects:
					 @"order",
					 @"url",
					 @"label",
					 @"section",
					 nil];
	
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:keys];
	return tempDict;
}

- (NSURL *) actualURL {	
	NSURL * actualURL = nil;
	
	if ([self.url isEqualToString:@"aboutView"]) {
		NSString *file = nil;

		if ([UtilityMethods isIPadDevice])
			file = @"TexLegeInfo~ipad.htm";
		else
			file = @"TexLegeInfo~iphone.htm";
		
		NSURL *baseURL = [UtilityMethods urlToMainBundle];
		actualURL = [NSURL URLWithString:file relativeToURL:baseURL];
	}
	else if ([self.url hasPrefix:@"http://www.followthemoney.org/"]) {
		NSString *tempString = @"http://www.followthemoney.org/";
		
		actualURL = [NSURL URLWithString:tempString];
	}
	else if ([self.url isEqualToString:@"contactMail"]) {
		actualURL = nil;
	}
	else if (self.url) {
		//NSURL *aURL = [UtilityMethods safeWebUrlFromString:self.url];
		actualURL = [NSURL URLWithString:self.url];
	}
	
	return actualURL;	
}

@end
