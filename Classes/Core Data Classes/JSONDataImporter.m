//
//  JSONDataImporter.m
//  TexLege
//
//  Created by Gregory Combs on 9/20/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "JSONDataImporter.h"
#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "LegislatorObj.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "TexLegeLibrary.h"
#import "OpenLegislativeAPIs.h"

@interface JSONDataImporter (Private)

- (void)verifyLegislatorsHaveOpenStatesID;
- (void)verifyCommitteesHaveOpenStatesID;

@end


@implementation JSONDataImporter


- (void)dealloc {
	[super dealloc];
}


// These methods will get data synchronously, on the main thread for simplicity 
// ... we won't be using these in production builds yet

/* array of dictionaries that look like:
	{
		"parent_id": null, 
		"chamber": "upper", 
		"state": "tx", 
		"votesmart_id": "11398", 
		"committee": "Education", 
		"id": "TXC000036", 
		"subcommittee": null
	} 
*/
- (NSArray *)getJSONCommitteesByChamber:(NSInteger)chamber {
	// http://openstates.sunlightlabs.com/api/v1/committees/?state=tx&active=true&chamber=upper&apikey=xxxxxxxxxxxxxxxx
	NSString *chamberString = [stringForChamber(chamber, TLReturnFull) lowercaseString];
	
	NSString *urlMethod = [NSString stringWithFormat:@"%@/committees/?state=tx&chamber=%@&%@", baseURL, chamberString, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON committees from url:%@ error:%@", url, error);
	}
	NSArray *jsonArray = [jsonString objectFromJSONStringWithParseOptions:(JKParseOptionUnicodeNewlines & JKParseOptionLooseUnicode)];
	return jsonArray;
}

/* dictionary that looks like:
	 {
		 "members": [
					 {
						 "leg_id": "TXL000187", 
						 "role": "member", 
						 "name": "Robert Duncan"
					 }, 
					 {
						 "leg_id": "TXL000211", 
						 "role": "member", 
						 "name": "John Whitmire"
					 }, 
					 {
						 "leg_id": "TXL000199", 
						 "role": "member", 
						 "name": "Jane Nelson"
					 }
					 ], 
		 "parent_id": null, 
		 "chamber": "upper", 
		 "state": "tx", 
		 "subcommittee": null, 
		 "committee": "Criminal Commitments of Indiv. w/ Mental Retardation, Select", 
		 "id": "TXC000065"
	 } 
 */

- (NSDictionary *)getJSONCommitteeInfoWithCommitteeID:(NSString *)committeeID {
	// http://openstates.sunlightlabs.com/api/v1/committees/TXC000065/?apikey=xxxxxxxxxxxxxxxx
	NSString *urlMethod = [NSString stringWithFormat:@"%@/committees/%@/?%@", baseURL, committeeID, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON committee from url:%@ error:%@", url, error);
	}
	NSDictionary *jsonDict = [jsonString objectFromJSONStringWithParseOptions:(JKParseOptionUnicodeNewlines & JKParseOptionLooseUnicode)];
	return jsonDict;
}

/*	 array of dictionaries that look like:
	 {
		 "first_name": "Bob",
		 "last_name": "Blumenfield",
		 "middle_name": "",
		 "district": "40",
		 "created_at": "2010-07-09 17:19:48",
		 "updated_at": "2010-08-30 21:41:37",
		 "chamber": "lower",
		 "state": "ca",
		 "nimsp_candidate_id": null,
		 "votesmart_id": "104387",
		 "full_name": "Blumenfield, Bob",
		 "leg_id": "CAL000088",
		 "party": "Democratic",
		 "photo_url": "http://www.assembly.ca.gov/images/members/40.jpg",
		 "active": true,
		 "id": "CAL000088",
		 "suffixes": ""
	 }
*/

- (NSArray *)getJSONLegislatorsByChamber:(NSInteger)chamber {
	// http://openstates.sunlightlabs.com/api/v1/legislators/?state=tx&chamber=%@&active=true&apikey=xxxxxxxxxxxxxxxx
	NSString *chamberString = [stringForChamber(chamber, TLReturnFull) lowercaseString];
	
	NSString *urlMethod = [NSString stringWithFormat:@"%@/legislators/?state=tx&chamber=%@&active=true&%@", baseURL, chamberString, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON legislators from url:%@ error:%@", url, error);
	}
	NSArray *jsonArray = [jsonString objectFromJSONStringWithParseOptions:(JKParseOptionUnicodeNewlines & JKParseOptionLooseUnicode)];
	
	return jsonArray;
}

/*	 dictionary that looks like:
	{
		"first_name": "Dora", 
		"last_name": "Olivo", 
		"middle_name": "", 
		"roles": [
				  {
					  "term": "81", 
					  "end_date": null, 
					  "district": "27", 
					  "chamber": "lower", 
					  "state": "tx", 
					  "party": "Democratic", 
					  "type": "member", 
					  "start_date": null
				  }, 
				  {
					  "term": "81", 
					  "end_date": null, 
					  "chamber": "lower", 
					  "state": "tx", 
					  "committee": "Public Education", 
					  "type": "committee member", 
					  "start_date": null
				  }
				  ], 
		"district": "27", 
		"chamber": "lower", 
		"created_at": "2010-06-19 03:51:42", 
		"+photo_url": "http://www.legdir.legis.state.tx.us/FlashCardDocs/images/House/small/A3886.jpg", 
		"updated_at": "2010-09-16 19:03:03", 
		"sources": [
					{
						"url": "http://www.legdir.legis.state.tx.us/MemberInfo.aspx?Chamber=H&Code=A3886", 
						"retrieved": "2010-09-16 18:39:41"
					}
					], 
		"state": "tx", 
		"nimsp_candidate_id": 100033, 
		"votesmart_id": "10019", 
		"full_name": "Dora Olivo", 
		"leg_id": "TXL000321", 
		"party": "Democratic", 
		"suffixes": "", 
		"active": true, 
		"id": "TXL000321", 
		"photo_url": "http://www.legdir.legis.state.tx.us/FlashCardDocs/images/House/small/A3886.jpg"
	}
*/

- (NSArray *)getJSONLegislatorInfoWithLegislatorID:(NSString *)legislatorID {
	// http://openstates.sunlightlabs.com/api/v1/legislators/TXL000321/?apikey=xxxxxxxxxxxxxxxx
	NSString *urlMethod = [NSString stringWithFormat:@"%@/legislators/%@/?%@", baseURL, legislatorID, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON legislator from url:%@ error:%@", url, error);
	}
	NSArray *jsonArray = [jsonString objectFromJSONStringWithParseOptions:(JKParseOptionUnicodeNewlines & JKParseOptionLooseUnicode)];
	return jsonArray;
}


- (void)verifyLegislatorsHaveOpenStatesID {	
	NSArray *legislators = [LegislatorObj allObjects];
	for (LegislatorObj *leg in legislators) {
		NSString *openstates = leg.openstatesID;
		if (!openstates || [openstates length] == 0) {
			debug_NSLog(@"No OpenStates ID for legislator: %@ -- %@", [leg legProperName], leg.legislatorID);
		}
	}

}


- (void)verifyCommitteesHaveOpenStatesID {
	//NSString *path = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"VotesmartToOpenStates.plist"];
	
	NSArray *committees = [CommitteeObj allObjects];
	for (CommitteeObj *com in committees) {
		NSString *openstates = com.openstatesID;
		if (!openstates || [openstates length] == 0) {
			debug_NSLog(@"No OpenStates ID for committee: %@ -- %@", [com committeeName], com.committeeId);
		}
	}
	
}


- (void)verifyCommitteeAssignmentsByChamber:(NSInteger)chamber {
	NSArray *jsonArray = [self getJSONCommitteesByChamber:chamber];
	if (!jsonArray)
		return;
	
	NSMutableArray *errors = [NSMutableArray array];
	NSMutableArray *identicals = [NSMutableArray array];
	NSMutableArray *missing = [NSMutableArray array];
	NSMutableArray *missingMembers = [NSMutableArray array];
	
	for (NSDictionary *summary in jsonArray) {
		NSString *idString = [summary objectForKey:@"id"];
		if (!idString || ![idString length]) {
			NSString *theErr = [NSString stringWithFormat:@"No OpenStates ID for openstate committee: %@ - id: %@", 
								[summary objectForKey:@"committee"], [summary objectForKey:@"id"]];
			[errors addObject:theErr];
			continue;
		}
		
		NSDictionary *dict = [self getJSONCommitteeInfoWithCommitteeID:idString];

		NSInteger hasMembers = ([dict objectForKey:@"members"] ? [[dict objectForKey:@"members"] count] : 0);
		if (hasMembers == 0)
			continue;
			
		// should we use openstates instead of votesmart??  where are we finding these committees?
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.openstatesID == %@", idString];
		CommitteeObj *committee  = [CommitteeObj objectWithPredicate:predicate];
		
		if (!committee) {
			NSString *theErr = [NSString stringWithFormat:@"(%d members -- ID:%@ - Committee: %@ - Chamber: %@", 
								hasMembers, idString, [dict objectForKey:@"committee"], [dict objectForKey:@"chamber"]];
			[missing addObject:theErr];
			continue;
		}
		
		NSMutableArray *currMembers = [NSMutableArray arrayWithCapacity:[committee.committeePositions count]];
		for (CommitteePositionObj *currentPosition in committee.committeePositions) {
			NSString *role = nil;
			switch ([currentPosition.position integerValue]) {
				case 2:
					role = @"chair";
					break;
				case 1:
					role = @"vice chair";
					break;
				case 0:
				default:
					role = @"member";
					break;
			}
			NSDictionary *positionDict = [NSDictionary dictionaryWithObjectsAndKeys:
										  currentPosition.legislator.openstatesID, @"leg_id",
										  role, @"role", 
										  nil];
										  
			[currMembers addObject:positionDict];
		}
		
		[currMembers sortUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
			NSString *leg_id1 = [item1 objectForKey:@"leg_id"];
			NSString *leg_id2 = [item2 objectForKey:@"leg_id"];
			return [leg_id1 compare:leg_id2 options:NSNumericSearch];
		}];
		
		NSMutableArray *jsonMembers = [NSMutableArray arrayWithCapacity:[[dict objectForKey:@"members"] count]];
		for (NSDictionary *jsonPosition in [dict objectForKey:@"members"]) {
			
			NSDictionary *positionDict = [NSDictionary dictionaryWithObjectsAndKeys:
										  [jsonPosition objectForKey:@"leg_id"], @"leg_id",
										  [jsonPosition objectForKey:@"role"], @"role",
										  nil];

			[jsonMembers addObject:positionDict];
		}

		[jsonMembers sortUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
			NSString *leg_id1 = [item1 objectForKey:@"leg_id"];
			NSString *leg_id2 = [item2 objectForKey:@"leg_id"];
			return [leg_id1 compare:leg_id2 options:NSNumericSearch];
		}];
		
		NSString *theStr = [NSString stringWithFormat:@"ID: %@ - Committee: %@ - Chamber: %@", 
							idString, committee.committeeName, [dict objectForKey:@"chamber"]];

		
		BOOL equal = [currMembers isEqualToArray:jsonMembers];
		if (equal) {
			[identicals addObject:theStr];
		}
		else {
			if ([currMembers count] != [jsonMembers count]) {
				[errors addObject:[NSString stringWithFormat:@"Different # (%d-%d)---- %@", [currMembers count], [jsonMembers count], theStr]];
			}
			else {
				[missing addObject:[NSString stringWithFormat:@"Same # (%d): wrong members ---- %@", hasMembers, theStr]];
				[missingMembers addObject:@"----- US ----"];
				[missingMembers addObject:[NSString stringWithFormat:@"%@", currMembers]];
				[missingMembers addObject:@"----- THEM ----"];
				[missingMembers addObject:[NSString stringWithFormat:@"%@", jsonMembers]];
				 
			}

		}
	}
	
	NSLog(@"ERRORS AND MISSING GO HERE: %@", [UtilityMethods applicationDocumentsDirectory]);
	
	NSString *fileOut = nil;
	if ([errors count]) {
		fileOut = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingFormat:@"/COMMITTEE_ERRORS_%d.txt", chamber];
		[errors writeToFile:fileOut atomically:YES];
/*	NSLog(@"ERRORS -----------------------------");
	for (NSString *different in errors) {
		NSLog(@"%@", different);
	}*/
	}

	if ([missing count]) {
		fileOut = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingFormat:@"/COMMITTEE_MISSING_%d.txt", chamber];
		[missing writeToFile:fileOut atomically:YES];

		/*	NSLog(@"MISSING -----------------------------");
		 for (NSString *different in missing) {
		 NSLog(@"%@", different);
		 }*/
	}
 
	
	if ([missingMembers count]) {
		fileOut = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingFormat:@"/COMMITTEE_MISSING_MEMBERS_%d.txt", chamber];
		[missingMembers writeToFile:fileOut atomically:YES];
		/*	NSLog(@"MISSING Members-----------------------------");
		 for (NSString *different in missingMembers) {
		 NSLog(@"%@", different);
		 }*/
	}
	
	//NSArray *friendsWithDadsNamedBob = [friends findAllWhereKeyPath:@"father.name" equals:@"Bob"]

}

@end
