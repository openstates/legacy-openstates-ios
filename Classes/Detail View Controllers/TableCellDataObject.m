//
//  DirectoryDetailInfo.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "TableCellDataObject.h"
#include "UtilityMethods.h"

@implementation TableCellDataObject
@synthesize entryValue, isClickable, entryType, title, subtitle, action, parameter;

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	if ([self init]) {
		
		if (!IsEmpty([aDictionary valueForKey:@"entryValue"]))
			self.entryValue = [aDictionary valueForKey:@"entryValue"];
		if (!IsEmpty([aDictionary valueForKey:@"entryType"]))
			self.entryType = [[aDictionary valueForKey:@"entryType"] integerValue];		
		if (!IsEmpty([aDictionary valueForKey:@"isClickable"]))
			self.isClickable = [[aDictionary valueForKey:@"isClickable"] boolValue];
		if (!IsEmpty([aDictionary valueForKey:@"title"]))
			self.title = [aDictionary valueForKey:@"title"];
		if (!IsEmpty([aDictionary valueForKey:@"subtitle"]))
			self.subtitle = [aDictionary valueForKey:@"subtitle"];
		if (!IsEmpty([aDictionary valueForKey:@"action"]))
			self.action = [aDictionary valueForKey:@"action"];
		if (!IsEmpty([aDictionary valueForKey:@"parameter"]))
			self.parameter = [aDictionary valueForKey:@"parameter"];
	}
	return self;
}


- (void)dealloc {
	self.entryValue = self.subtitle = self.title = nil;
	self.parameter = nil;
	self.action = nil;
	
    [super dealloc];
}

- (NSString *)description {
	NSString *string = [NSString stringWithFormat:@"CellDataObject properties: \
						title = %@ \
						subtitle = %@ \
						entryValue = %@ \
						entryType = %d \
						isClickable = %d \
						action = %@ \
						parameter = %@", 
						self.title, self.subtitle, self.entryValue, self.entryType, self.isClickable, self.action, self.parameter];
	return string;
}

- (NSURL *)generateURL {
	NSURL * tempURL = nil;

	if (![entryValue isEqualToString:@""]) { // Make sure we have something to give...
		switch (entryType) {
			case DirectoryTypePhone:
				tempURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",entryValue]];
				break;
			case DirectoryTypeWeb:
				tempURL = [UtilityMethods safeWebUrlFromString:entryValue];
				break;
			case DirectoryTypeMail:
				tempURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",entryValue]];
				break;
			case DirectoryTypeSMS:
				tempURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@",entryValue]];
				break;
			case DirectoryTypeTwitter: {
				NSMutableString *twitString = [NSMutableString stringWithString:entryValue];
				if ([twitString hasPrefix:@"@"])
					[twitString deleteCharactersInRange:NSMakeRange(0, 1)];
				
				NSString *interAppTwitter = [NSString stringWithFormat:@"twitter://user?screen_name=%@", twitString];
				NSURL *interAppTwitterURL = [NSURL URLWithString:interAppTwitter];
				
				if ([[UIApplication sharedApplication] canOpenURL:interAppTwitterURL]) {
					tempURL = interAppTwitterURL;
				}
				else {
					[twitString insertString:@"http://m.twitter.com/" atIndex:0];
					tempURL = [NSURL URLWithString:twitString];
				}
			}
				break;
			default:
				tempURL = nil;
				break;
		}
	}

	return tempURL;	
}


@end
