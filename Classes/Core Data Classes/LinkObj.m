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

@dynamic sortOrder;
@dynamic url;
@dynamic label;
@dynamic section;
@dynamic updated;

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"sortOrder", @"sortOrder",
			@"url", @"url",
			@"label", @"label",
			@"section", @"section",
			@"updated", @"updated",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"sortOrder";
}

#pragma mark Core Data Initialization

/*
- (id)proxyForJson {
	NSDictionary *tempDict = [self dictionaryWithValuesForKeys:[[[self class] elementToPropertyMappings] allKeys]];	
	return tempDict;	
}
*/
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
	else if ([self.url isEqualToString:@"mailto:support@texlege.com"]) {
		actualURL = nil;
	}
	else if (self.url) {
		//NSURL *aURL = [UtilityMethods safeWebUrlFromString:self.url];
		actualURL = [NSURL URLWithString:self.url];
	}
	
	return actualURL;	
}

@end
