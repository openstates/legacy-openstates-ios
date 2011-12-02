//
//  NSString+DKAdditions.h
//  Created by Gregory Combs on 6/11/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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

