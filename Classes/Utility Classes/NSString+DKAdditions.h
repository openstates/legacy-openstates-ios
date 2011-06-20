//
//  NSString+DKAdditions.h
//  TexLege
//
//  Created by Gregory Combs on 6/11/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(DKAdditions)

- (NSComparisonResult) localisedCaseInsensitiveNumericCompare:(NSString*) anotherString;

- (NSString*)  stringByCapitalizingFirstCharacter;
	// returns a copy of the receiver with just the first character capitalized, ignoring all others. Thus, the rest of the string isn't necessarily forced to
	// lowercase, as happens in [NSString capitalizedString]


- (NSString*) abbreviateStringWithDictionary:(NSDictionary*) abbreviations;
	// breaks a string into words. If any words are keys in the dictionary, the word is substituted by its value. 
	// Keys are case insensitive (dictionary should have lower case keys) and words are substituted 
	// with the verbatim value. If dictionary is nil, self is returned.
@end

