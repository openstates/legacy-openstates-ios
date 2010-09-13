//
//  DirectoryDetailInfo.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "DirectoryDetailInfo.h"
#import "LegislatorObj.h"
#include "UtilityMethods.h"

@implementation DirectoryDetailInfo
@synthesize /*entryName, */entryValue, isClickable, entryType, title, subtitle;

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	if ([self init]) {
		
		//self.entryName = [aDictionary valueForKey:@"entryName"];
		self.entryValue = [aDictionary valueForKey:@"entryValue"];
		self.entryType = [[aDictionary valueForKey:@"entryType"] integerValue];		
		self.isClickable = [[aDictionary valueForKey:@"isClickable"] boolValue];
		self.title = [aDictionary valueForKey:@"title"];
		self.subtitle = [aDictionary valueForKey:@"subtitle"];
	}
	return self;
}


- (void)dealloc {
	self.entryValue = self.subtitle = self.title = nil;
	
    [super dealloc];
}

- (NSURL *)generateURL:(LegislatorObj *)legislator {
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
					[twitString deleteCharactersInRange:NSMakeRange(0, 1)]; // delete the initial "@" character.
				tempURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.twitter.com/%@",twitString]];
			}
				break;
/*			case DirectoryTypeMap:
				tempURL = [UtilityMethods googleMapUrlFromStreetAddress:entryValue];
				break;
*/
			default:
				tempURL = nil;
				break;
		}
	}

	return tempURL;	
}


@end
