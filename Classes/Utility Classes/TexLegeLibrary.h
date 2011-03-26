//
//  TexLegeLibrary.h
//  TexLege
//
//  Created by Gregory Combs on 2/4/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#define OPENAPIS_DEFAULT_SESSION		@"82"
#define WNOM_DEFAULT_LATEST_SESSION		81

// Legislative Chamber / Legislator Type
enum kChambers {
    BOTH_CHAMBERS = 0,
    HOUSE,
    SENATE,
	JOINT	
};

// Political Party
enum kParties {
    kUnknownParty = 0,
    DEMOCRAT,
    REPUBLICAN
};

// Committe Position Roles
enum kPositions {
    POS_MEMBER = 0,
    POS_VICE,
    POS_CHAIR
};

typedef enum  {
    TLReturnFull = 0,		// Return the full string
    TLReturnAbbrev,			// Return an abbreviation
    TLReturnInitial,		// Return an initial
	TLReturnOpenStates
} TLStringReturnType;

NSInteger chamberForString(NSString *chamberString);
NSString *stringForChamber(NSInteger chamber, TLStringReturnType type);
NSString *stringForParty(NSInteger party, TLStringReturnType type);