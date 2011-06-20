//  NSString+DKAdditions.m
//  GCDrawKit
//
//  Created by graham on 12/08/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "NSString+DKAdditions.h"


@implementation NSString(DKAdditions)


- (NSComparisonResult) localisedCaseInsensitiveNumericCompare:(NSString*) anotherString
{
	return [self compare:anotherString options:NSCaseInsensitiveSearch | 
			NSNumericSearch range:NSMakeRange(0, [self length]) 
				  locale:[NSLocale currentLocale]];
}

- (NSString*)  stringByCapitalizingFirstCharacter
{
	// returns a copy of the receiver with just the first character capitalized, ignoring all others. Thus, the rest of the string isn't necessarily forced to
	// lowercase, as happens in [NSString capitalizedString]
	
	NSMutableString* sc = [[self mutableCopy] autorelease];
	
	if([self length] > 0 )
		[sc replaceCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] uppercaseString]];
	
	return sc;
}


- (NSString*) abbreviateStringWithDictionary:(NSDictionary*) abbreviations
{
	// breaks a string into words. If any words are keys in the dictionary, the word is substituted by its value. 
	// Keys are case insensitive (dictionary should have lower case keys) and words are substituted 
	// with the verbatim value. If dictionary is nil, self is returned.
	
	if( abbreviations == nil )
		return self;
	
	NSMutableString* result = [NSMutableString string];
	NSString*  newWord;
	
	for(NSString* word in [self componentsSeparatedByString:@" "])
	{
		newWord = [abbreviations objectForKey:[word lowercaseString]];
		
		if( newWord ) {
			word = newWord;
		}
		[result appendFormat:@"%@ ", word];
	}
	[result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];
	
	return result;
}

@end