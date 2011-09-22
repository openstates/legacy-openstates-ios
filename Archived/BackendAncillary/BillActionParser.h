//
//  BillActionParser.h
//  Created by Gregory Combs on 6/12/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

typedef enum BillType {
	BillTypeSimpleResolution = 0,	// Stages 1-3 (2 is optional)
	BillTypeConcurrentResolution,	// Stages 1-5, 6&7 optional/unknown
	BillTypeJointResolution,		// Stages 1-5, 6 (sec of state), 7 (after voter approval)
	BillTypeBill,					// Stages 1-7
} BillType;

@class SLFBill;
@interface BillActionParser : NSObject {
}

- (NSMutableDictionary *)parseStagesForBill:(SLFBill *)bill;

@end



/*
 
bill:filed
bill:introduced
	Bill is introduced or prefiled
bill:passed
	Bill has passed a chamber
bill:failed
	Bill has failed to pass a chamber
bill:withdrawn
	Bill has been withdrawn from consideration
bill:veto_override:passed
	The chamber attempted a veto override and succeeded
bill:veto_override:failed
	The chamber attempted a veto override and failed
bill:reading:1
	A bill has undergone its first reading
bill:reading:2
	A bill has undergone its second reading
bill:reading:3
	A bill has undergone its third (or final) reading
governor:received
	The bill has been transmitted to the governor for consideration
governor:signed
	The bill has signed into law by the governor
governor:vetoed
	The bill has been vetoed by the governor
governor:vetoed:line-item
	The governor has issued a line-item (partial) veto
amendment:introduced
	An amendment has been offered on the bill
amendment:passed
	The bill has been amended
amendment:failed
	An offered amendment has failed
amendment:amended
	An offered amendment has been amended (seen in Texas)
amendment:withdrawn
	An offered amendment has been withdrawn
committee:referred
	The bill has been referred to a committee
committee:passed
	The bill has been passed out of a committee
committee:passed:favorable
	The bill has been passed out of a committee with a favorable report
committee:passed:unfavorable
	The bill has been passed out of a committee with an unfavorable report
committee:failed
	The bill has failed to make it out of committee
other
	All other actions will have a type of "other"
*/
