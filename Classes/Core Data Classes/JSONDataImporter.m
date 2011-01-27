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
#import "JSON.h"

static const NSString *baseURL = @"http://openstates.sunlightlabs.com/api/v1";
static const NSString *apiKey = @"apikey=350284d0c6af453b9b56f6c1c7fea1f9";
@interface JSONDataImporter (Private)

- (void)verifyLegislatorsHaveOpenStatesID;
- (void)verifyCommitteesHaveOpenStatesID;

@end


@implementation JSONDataImporter
@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
	if (self = [super init]) {
		if (context) {
			if (managedObjectContext)
				[managedObjectContext release], managedObjectContext = nil;
			managedObjectContext = [context retain];
			
			//[self verifyLegislatorsHaveOpenStatesID];
			//[self verifyCommitteesHaveOpenStatesID];

		}
	}
	return self;
}

- (void)dealloc {
	self.managedObjectContext = nil;
	[super dealloc];
}

- (NSManagedObjectContext *)managedObjectContext {
	if (!managedObjectContext) {
		self.managedObjectContext = [[TexLegeAppDelegate appDelegate] managedObjectContext];
	}
	return (managedObjectContext);
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
	// http://openstates.sunlightlabs.com/api/v1/committees/?state=tx&active=true&chamber=upper&apikey=350284d0c6af453b9b56f6c1c7fea1f9
	NSString *chamberString = @"";
	if (chamber == HOUSE)
		chamberString = @"lower";
	else if (chamber == SENATE)
		chamberString = @"upper";
	
	NSString *urlMethod = [NSString stringWithFormat:@"%@/committees/?state=tx&chamber=%@&%@", baseURL, chamberString, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON committees from url:%@ error:%@", url, error);
	}
	NSArray *jsonArray = [jsonString JSONValue];
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
	// http://openstates.sunlightlabs.com/api/v1/committees/TXC000065/?apikey=350284d0c6af453b9b56f6c1c7fea1f9	
	NSString *urlMethod = [NSString stringWithFormat:@"%@/committees/%@/?%@", baseURL, committeeID, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON committee from url:%@ error:%@", url, error);
	}
	NSDictionary *jsonDict = [jsonString JSONValue];
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
	// http://openstates.sunlightlabs.com/api/v1/legislators/?state=tx&chamber=%@&active=true&apikey=350284d0c6af453b9b56f6c1c7fea1f9
	NSString *chamberString = @"";
	if (chamber == HOUSE)
		chamberString = @"lower";
	else if (chamber == SENATE)
		chamberString = @"upper";
	
	NSString *urlMethod = [NSString stringWithFormat:@"%@/legislators/?state=tx&chamber=%@&active=true&%@", baseURL, chamberString, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON legislators from url:%@ error:%@", url, error);
	}
	NSArray *jsonArray = [jsonString JSONValue];
	
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
	// http://openstates.sunlightlabs.com/api/v1/legislators/TXL000321/?apikey=350284d0c6af453b9b56f6c1c7fea1f9	
	NSString *urlMethod = [NSString stringWithFormat:@"%@/legislators/%@/?%@", baseURL, legislatorID, apiKey];
	NSURL *url = [NSURL URLWithString:urlMethod];
	NSError *error = nil;
	NSString * jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		debug_NSLog(@"Error retrieving JSON legislator from url:%@ error:%@", url, error);
	}
	NSArray *jsonArray = [jsonString JSONValue];
	return jsonArray;
}


- (void)verifyLegislatorsHaveOpenStatesID {	
	NSArray *legislators = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"LegislatorObj" context:self.managedObjectContext];
	for (LegislatorObj *leg in legislators) {
		NSString *openstates = leg.openstatesID;
		if (!openstates || [openstates length] == 0) {
			debug_NSLog(@"No OpenStates ID for legislator: %@ -- %@", [leg legProperName], leg.legislatorID);
		}
	}

}


- (void)verifyCommitteesHaveOpenStatesID {
	//NSString *path = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:@"VotesmartToOpenStates.plist"];
	
	NSArray *committees = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"CommitteeObj" context:self.managedObjectContext];
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
	for (NSDictionary *dict in jsonArray) {
		// should we use openstates instead of votesmart??  where are we finding these committees?
		
		NSString *idString = [dict objectForKey:@"id"];
		if (!idString || ![openStatesID length]) {
			debug_NSLog(@"No OpenStates ID  for committee: %@ - id: %@", [dict objectForKey:@"committee"], [dict objectForKey:@"id"]);
			continue;
		}
		NSNumber *openStatesID = [NSNumber numberWithInteger:[idString integerValue]];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.openstatesID == %@", openStatesID];
		CommitteeObj *committee  = [TexLegeCoreDataUtils dataObjectWithPredicate:predicate entityName:@"CommitteeObj" context:self.managedObjectContext];
		
		if (!committee) {
			debug_NSLog(@"No committee object found for: %@ - openStatesID: %@", [dict objectForKey:@"committee"], openStatesID);
			continue;
		}
		
		NSMutableArray *currMembers = [NSMutableArray arrayWithCapacity:[committee.committeePositions count]];
		for (CommitteePositionObj *currentPosition in committee.committeePositions) {
			[currMembers addObject:currentPosition.legislatorID];
		}
		
		NSMutableArray *jsonMembers = [NSMutableArray arrayWithCapacity:[[dict objectForKey:@"members"] count]];
		for (NSDictionary *jsonPosition in [dict objectForKey:@"members"]) {
			[jsonMembers addObject:[jsonPosition objectForKey:@"leg_id"]];
		}
		
#warning unfinished ... needs some sort of comparison between these two arrays

	}
	
	//NSArray *currentCommittees = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"CommitteeObj" context:self.managedObjectContext];

	
	//NSArray *currentPositions = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"CommitteePositionObj" context:self.managedObjectContext];
	
	
	//NSArray *friendsWithDadsNamedBob = [friends findAllWhereKeyPath:@"father.name" equals:@"Bob"]

	
}

@end
