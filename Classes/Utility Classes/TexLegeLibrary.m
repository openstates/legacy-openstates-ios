//
//  TexLegeLibrary.m
//  Created by Gregory Combs on 2/4/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TexLegeLibrary.h"
#import "UtilityMethods.h"
#import "StateMetaLoader.h"
#import "SLFState.h"

NSString *stringInitial(NSString *inString, BOOL parens) {
	if (IsEmpty(inString))
		return nil;
	NSString * initial = [inString substringToIndex:1];
	if ([inString isEqualToString:NSLocalizedStringFromTable(@"All", @"DataTableUI", @"As in all chambers")] 
		|| [inString isEqualToString:NSLocalizedStringFromTable(@"Both", @"DataTableUI", @"As in both chambers")]) {
		initial = inString;
	}
	if (parens) {
		initial = [NSString stringWithFormat:@"(%@)", initial];
	}
	return initial;

}

NSString *abbreviateString(NSString *inString) {
	if (IsEmpty(inString))
		return nil;
	
	NSString *outString = NSLocalizedStringFromTable(inString, @"Abbreviations", @"");
	if (IsEmpty(outString)) {
		outString = inString;
	}
	return outString;
}

NSString *stringForChamber(NSInteger chamber, TLStringReturnType type) {
    SLFState *aState = [[StateMetaLoader sharedStateMeta] selectedState];
	
	NSString *chamberName = [aState nameForChamber:chamber];	
	
	if (IsEmpty(chamberName)) {	// in case we didn't get it already
		switch (chamber) {
			case HOUSE:
				chamberName = NSLocalizedStringFromTable(@"House", @"DataTableUI", @"House of Representatives");
				break;
			case SENATE:
				chamberName = NSLocalizedStringFromTable(@"Senate", @"DataTableUI", @"");
				break;
			case JOINT:
				chamberName = NSLocalizedStringFromTable(@"Joint", @"DataTableUI", @"As in a joint committee");
				break;
			case BOTH_CHAMBERS:
				chamberName = NSLocalizedStringFromTable(@"All", @"DataTableUI", @"As in all chambers");
				break;
		}
	}
	
	if (type == TLReturnAbbrev)
		return abbreviateString(chamberName);
	
	if (type == TLReturnFull)
		return chamberName;
	
	if (type == TLReturnInitial)
		return stringInitial(chamberName, YES);
	
	if (type == TLReturnTitle ) {
		NSString *title = nil;
		
		if (chamber == HOUSE || chamber == SENATE) {
			if (aState) {
				if (chamber == HOUSE)
					title = aState.lowerChamberTitle;
				else if (chamber == SENATE)
					title = aState.upperChamberTitle;
			}
		}			
		if (IsEmpty(title)) {
			switch (chamber) {
				case SENATE:
					title = NSLocalizedStringFromTable(@"Senator", @"DataTableUI", @"");
					break;
				case HOUSE:
					title = NSLocalizedStringFromTable(@"Representative", @"DataTableUI", @"");
					break;
				case JOINT:
					title = NSLocalizedStringFromTable(@"Joint", @"DataTableUI", @"As in a joint committee");
					break;
			}
		}
		
		return title;
	
	}			

	if (type == TLReturnOpenStates) {
		switch (chamber) {
			case SENATE:
				chamberName = @"upper";
				break;
			case HOUSE:
				chamberName = @"lower";
				break;
			case JOINT:
				chamberName = @"joint";
				break;
			case EXECUTIVE:
				chamberName = @"executive";
				break;
			case BOTH_CHAMBERS:
			default:
				chamberName = @"";
				break;
		}
	}
	return chamberName;
}

NSString * chamberStringFromOpenStates(NSString *chamberString) {
    NSInteger chamber = chamberIntFromOpenStates(chamberString);
    return stringForChamber(chamber, TLReturnFull);
}

NSInteger chamberIntFromOpenStates(NSString *chamberString) {	// upper, lower, joint ...	
	NSInteger chamber = BOTH_CHAMBERS;
	
	if (NO == IsEmpty(chamberString)) {
		if ([chamberString caseInsensitiveCompare:@"upper"] == NSOrderedSame)
			chamber = SENATE;
		else if ([chamberString caseInsensitiveCompare:@"lower"] == NSOrderedSame)
			chamber = HOUSE;
		else if ([chamberString caseInsensitiveCompare:@"joint"] == NSOrderedSame)
			chamber = JOINT;
		else if ([chamberString caseInsensitiveCompare:@"executive"] == NSOrderedSame)
			chamber = EXECUTIVE;
	}
	
	return chamber;
	
}


NSString *stringForParty(NSInteger party, TLStringReturnType type) {
	NSString *partyString = nil;
	
	switch (party) {
		case DEMOCRAT:
			partyString = NSLocalizedStringFromTable(@"Democrat", @"DataTableUI", @"");
			break;
		case REPUBLICAN:
			partyString = NSLocalizedStringFromTable(@"Republican", @"DataTableUI", @"");
			break;
		default:
			partyString = NSLocalizedStringFromTable(@"Independent", @"DataTableUI", @"");
			break;
	}		
	
	if (type == TLReturnFull)
		return partyString;
	
	if (type == TLReturnInitial)
		partyString = stringInitial(partyString, NO);

	if (type == TLReturnAbbrev)
		partyString = abbreviateString(partyString);
	
	if (type == TLReturnAbbrevPlural)
		partyString = abbreviateString([partyString stringByAppendingString:@"s"]);
	
	return partyString;
}


NSString * watchIDForBill(NSDictionary *aBill) {
	if (aBill && [aBill objectForKey:@"session"] && [aBill objectForKey:@"bill_id"])
		return [NSString stringWithFormat:@"%@:%@", [aBill objectForKey:@"session"],[aBill objectForKey:@"bill_id"]]; 
	else
		return @"";
}


