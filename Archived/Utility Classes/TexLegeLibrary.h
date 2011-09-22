//
//  TexLegeLibrary.h
//  Created by Gregory Combs on 2/4/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

typedef enum  {
    TLReturnFull = 0,		// Return the full string
    TLReturnAbbrev,			// Return an abbreviation
    TLReturnInitial,		// Return an initial
	TLReturnOpenStates,
	TLReturnAbbrevPlural,	// Like "Dems", "Repubs", etc.
	TLReturnTitle			// Return a member title like Senator or Representative
} TLStringReturnType;


NSString *stringInitial(NSString *inString, BOOL parens);
NSString *abbreviateString(NSString *inString);

    //NSString * chamberStringFromOpenStates(NSString *chamberString);
    //NSInteger chamberIntFromOpenStates(NSString *chamberString);
    //NSString *stringForChamber(NSInteger chamber, TLStringReturnType type);

NSString *stringForParty(NSInteger party, TLStringReturnType type);


