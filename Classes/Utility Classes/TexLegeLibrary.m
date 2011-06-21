//
//  TexLegeLibrary.m
//  TexLege
//
//  Created by Gregory Combs on 2/4/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "TexLegeLibrary.h"
#import "UtilityMethods.h"
#import "StateMetaLoader.h"

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
	NSDictionary *stateMeta = [[StateMetaLoader sharedStateMeta] stateMetadata];

	NSString *chamberName = nil;
	if (NO == IsEmpty(stateMeta)) {
		if (chamber == SENATE)
			chamberName = [stateMeta objectForKey:kMetaUpperChamberNameKey];
		else if (chamber == HOUSE) {
			chamberName = [stateMeta objectForKey:kMetaLowerChamberNameKey];
		}
		if (NO == IsEmpty(chamberName)) {	// shorten the ting if its a couple of sentences long
			chamberName = abbreviateString(chamberName);	
			// Just shortens it to the first word (at least that's how we set it up in the file
			
			/*
			NSArray *words = [chamberName componentsSeparatedByString:@" "];
			if ([words count] > 1 && [[words objectAtIndex:0] length] > 4) { // just to make sure we have a decent, single name
				chamberName = [words objectAtIndex:0];
			}*/
		}
	}
	
	
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
	
	if (type == TLReturnFull)
		return chamberName;
	
	if (type == TLReturnInitial)
		return stringInitial(chamberName, YES);
	
	if (type == TLReturnAbbrev || type == TLReturnTitle ) {
		NSString *title = nil;
		
		if (chamber == HOUSE || chamber == SENATE) {
			if (NO == IsEmpty(stateMeta)) {
				if (chamber == HOUSE)
					title = [stateMeta objectForKey:kMetaLowerChamberTitleKey];
				else if (chamber == SENATE)
					title = [stateMeta objectForKey:kMetaUpperChamberTitleKey];
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
				case BOTH_CHAMBERS:
				case JOINT:
					title = NSLocalizedStringFromTable(@"Joint", @"DataTableUI", @"As in a joint committee");
					break;
			}
		}
		
		if (type == TLReturnAbbrev && NO == IsEmpty(title))
			title = abbreviateString(title);			
		
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

NSInteger chamberFromOpenStatesString(NSString *chamberString) {	// upper, lower, joint ...	
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

#warning state specific (Bill IDs)

NSString *billTypeStringFromBillID(NSString *billID) {
	NSArray *words = [billID componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (!IsEmpty(words))
		return [words objectAtIndex:0];
	else
		return nil;
}

NSString * watchIDForBill(NSDictionary *aBill) {
	if (aBill && [aBill objectForKey:@"session"] && [aBill objectForKey:@"bill_id"])
		return [NSString stringWithFormat:@"%@:%@", [aBill objectForKey:@"session"],[aBill objectForKey:@"bill_id"]]; 
	else
		return @"";
}


