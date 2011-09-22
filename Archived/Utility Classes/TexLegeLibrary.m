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
#import "SLFDataModels.h"

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



