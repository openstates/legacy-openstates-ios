//
//  LegislatorContributionsDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 9/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LegislatorContributionsDataSource.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeStandardGroupCell.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>

@interface LegislatorContributionsDataSource(Private)
- (void)parseJSONObject:(id)jsonDeserialized;
@end

@implementation LegislatorContributionsDataSource
@synthesize sectionList, queryEntityID, queryType, queryCycle;

- (NSString *)title {
	NSString *title = nil;
	
	switch ([self.queryType integerValue]) {
		case kContributionQueryTop10Donors:
			title = NSLocalizedStringFromTable(@"Top Contributions", @"DataTableUI", @"Title for table listing top 10 campaign donors.");
			break;
		case kContributionQueryTop10Recipients:
		case kContributionQueryTop10RecipientsIndiv:
			title = NSLocalizedStringFromTable(@"Top Recipients", @"DataTableUI", @"Title for table listing top 10 campaign donation recipients");
			break;
		case kContributionQueryRecipient:
			title = NSLocalizedStringFromTable(@"Recipient Details", @"DataTableUI", @"Title for table listing details of a recipient of campaign money");
			break;
		case kContributionQueryDonor:
		case kContributionQueryIndividual:
			title = NSLocalizedStringFromTable(@"Contributor Details", @"DataTableUI", @"Title for table listing details for campaign contributors");
			break;
		case kContributionQueryEntitySearch:
			title = NSLocalizedStringFromTable(@"Entity Search", @"DataTableUI", @"Title for cell that allows user to search for a campaign donation recipient or contributor.");
			break;
		default:
			title = @"";
			break;
	}
	
	if (!IsEmpty(self.queryCycle)) {
		NSString *year = self.queryCycle;
		if (![year isEqualToString:@"-1"])
			title = [NSString stringWithFormat:@"%@ %@", year, title];
	}
	return title;
}


- (void)dealloc {
	self.queryCycle = nil;
	self.sectionList = nil;
	self.queryEntityID = nil;
	self.queryType = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	if (!IsEmpty(self.sectionList))
		return [self.sectionList count];
	else
		return 0;
}

// This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index; // index ..........
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	NSInteger count = 0;
	if (self.sectionList) {
		NSArray *group = [self.sectionList objectAtIndex:section];
		if (group)
			count = [group count];
	}
	return count;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = NSLocalizedStringFromTable(@"Contributions",@"DataTableUI", @"Listing campaign contributions");
	
	switch ([self.queryType integerValue]) {
		case kContributionQueryRecipient:
			title = (section == 0) ? 
				NSLocalizedStringFromTable(@"Recipient Information", @"DataTableUI",@"Information for campaign contribution recipients")
					: NSLocalizedStringFromTable(@"Aggregate Contributions", @"DataTableUI",@"Total campaign contributions for someone");
			break;
		case kContributionQueryDonor: 
		case kContributionQueryIndividual:
			title = (section == 0) ? 
				NSLocalizedStringFromTable(@"Contributor Information", @"DataTableUI",@"Campaign contributor information")
					: NSLocalizedStringFromTable(@"Contributions (to everyone)", @"DataTableUI",@"Details of campaign contributions");
			break;
		case kContributionQueryTop10Donors:
			title = NSLocalizedStringFromTable(@"Biggest Contributors", @"DataTableUI",@"Top 10 campaign donors");
			break;
		case kContributionQueryTop10Recipients:
		case kContributionQueryTop10RecipientsIndiv:
			title = NSLocalizedStringFromTable(@"Biggest Recipients", @"DataTableUI", @"Top 10 campaign donation recipients");
			break;
		case kContributionQueryEntitySearch:
			title = NSLocalizedStringFromTable(@"Search Closest Matching Entity", @"DataTableUI", @"Allows user to search for campaign donation information");
			break;
		default:
			break;
	}
	return title;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	TableCellDataObject *cellInfo = [self dataObjectForIndexPath:indexPath];
	
	if (cellInfo == nil) {
		debug_NSLog(@"ContributionsDataSource: error finding table entry for section:%d row:%d", indexPath.section, indexPath.row);
		return nil;
	}
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"%@-%d", [TexLegeStandardGroupCell cellIdentifier], cellInfo.isClickable];
	
	/* Look up cell in the table queue */
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
		UITableViewCellStyle style;
		
		if (([self.queryType integerValue] == kContributionQueryTop10Donors) || 
			([self.queryType integerValue] == kContributionQueryTop10Recipients) ||
			([self.queryType integerValue] == kContributionQueryTop10RecipientsIndiv))
			style = UITableViewCellStyleValue1;
		else
			style = [TexLegeStandardGroupCell cellStyle];
		
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier] autorelease];
    }
    
	if ([cell conformsToProtocol:@protocol(TexLegeGroupCellProtocol)])
		[cell performSelector:@selector(setCellInfo:) withObject:cellInfo];
	
	[cell sizeToFit];
	[cell setNeedsDisplay];
	return cell;
}

#pragma mark -
#pragma mark Data Query

- (void)initiateQueryWithQueryID:(NSString *)aQuery type:(NSNumber *)type cycle:(NSString *)cycle {
	self.queryEntityID = aQuery;
	self.queryType = type;
	self.queryCycle = cycle;
	
	NSString *resourcePath = nil;
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										osApiKeyValue, @"apikey",
										self.queryCycle, @"cycle",nil];
	switch ([self.queryType integerValue]) {
		case kContributionQueryEntitySearch:
			[queryParams removeObjectForKey:@"cycle"];
			[queryParams setObject:aQuery forKey:@"search"];	
			resourcePath = @"/entities.json";
			break;
		case kContributionQueryTop10Donors:
			resourcePath = [NSString stringWithFormat:@"/aggregates/pol/%@/contributors.json", aQuery];
			break;
		case kContributionQueryTop10RecipientsIndiv:
			resourcePath = [NSString stringWithFormat:@"/aggregates/indiv/%@/recipient_pols.json", aQuery];
			break;
		case kContributionQueryTop10Recipients:
			resourcePath = [NSString stringWithFormat:@"/aggregates/org/%@/recipients.json", aQuery];
			break;
		case kContributionQueryRecipient:
		case kContributionQueryDonor:
		case kContributionQueryIndividual:
		default:
			resourcePath = [NSString stringWithFormat:@"/entities/%@.json", aQuery];;
			break;
	}
	
	debug_NSLog(@"Contributions resource path: %@", resourcePath);
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:transApiBaseURL] alert:YES]) {
		[[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] transApiClient] get:resourcePath queryParams:queryParams delegate:self];
	}
}


- (void)parseJSONObject:(id)jsonDeserialized {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	[numberFormatter setMaximumFractionDigits:0];
	
	if (!self.sectionList)
		self.sectionList = [NSMutableArray array];
	
	if ([self.queryType integerValue] == kContributionQueryEntitySearch) {
		NSArray *jsonArray = jsonDeserialized;	
		
		// only one section right now
		[self.sectionList removeAllObjects];
		
		NSMutableArray *thisSection = [[NSMutableArray alloc] init];
		
		for (NSDictionary *dict in jsonArray) {
			NSString *localizedString = NSLocalizedStringFromTable(@"Unknown", @"DataTableUI", @"This is an unknown entity (person, company, group, etc)");
			
			NSString *entityType = [[dict objectForKey:@"type"] capitalizedString];
			//NSString *valueKey = @"";
			NSNumber *action = nil;
			if ([entityType isEqualToString:@"Politician"]) {
				//valueKey = @"total_received";
				localizedString = NSLocalizedStringFromTable(@"Politician", @"DataTableUI", @"The entity is a politician");
				action = [NSNumber numberWithInteger:kContributionQueryRecipient];
			}
			else if ([entityType isEqualToString:@"Organization"]) {
				//valueKey = @"total_given";
				localizedString = NSLocalizedStringFromTable(@"Organization", @"DataTableUI", @"The entity is an organization or interest group");
				action = [NSNumber numberWithInteger:kContributionQueryDonor];
			}
			else if ([entityType isEqualToString:@"Individual"]) {
				//valueKey = @"total_given";
				localizedString = NSLocalizedStringFromTable(@"Individual", @"DataTableUI", @"The entity is an individual / private citizen");
				action = [NSNumber numberWithInteger:kContributionQueryIndividual];
			}
			
			TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.title = [dict valueForKey:@"name"];
			cellInfo.subtitle = localizedString;
			cellInfo.entryValue = [dict objectForKey:@"id"];
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = YES;
			cellInfo.action = action;
			cellInfo.parameter = @"-1";
			
			[thisSection addObject:cellInfo];
			[cellInfo release];
		}
		
		if (![jsonArray count]) {	// no search results!
			NSString *name = [self.queryEntityID stringByReplacingOccurrencesOfString:@"+" withString:@" "];
			
			TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.title = name;
			cellInfo.subtitle = NSLocalizedStringFromTable(@"Nothing for", @"DataTableUI", @"There is no information available for .... someone");
			cellInfo.entryValue = nil;
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = NO;
			cellInfo.action = nil;
			cellInfo.parameter = nil;
			
			[thisSection addObject:cellInfo];
			[cellInfo release];
		}
		[self.sectionList addObject:thisSection];
		[thisSection release];
		
	}
	else if ([self.queryType integerValue] == kContributionQueryTop10RecipientsIndiv) {
		NSArray *jsonArray = jsonDeserialized;	
		
		// only one section right now
		[self.sectionList removeAllObjects];
		
		NSMutableArray *thisSection = [[NSMutableArray alloc] init];
		
		for (NSDictionary *dict in jsonArray) {
			double tempDouble = [[dict objectForKey:@"amount"] doubleValue];
			NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
			
			TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
			NSString *name = [[dict objectForKey:@"recipient_name"] capitalizedString];
			
			id dataID = [dict objectForKey:@"recipient_entity"];

			cellInfo.title = name;
			cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = dataID;
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = YES;
			cellInfo.parameter = self.queryCycle;
			cellInfo.action = [NSNumber numberWithInteger:kContributionQueryRecipient];

#warning state specific (Bob Perry Contributions)

			if (!dataID || [[NSNull null] isEqual:dataID] || ![dataID isKindOfClass:[NSString class]]) {
				NSLog(@"ERROR - Contribution results have an empty entity ID for: %@", name);								
				if ([[name uppercaseString] isEqualToString:@"BOB PERRY HOMES"])	// ala Bob Perry Homes
					name = @"Perry Homes";
				else if ([[name uppercaseString] hasPrefix:@"BOB PERRY"])	// ala Bob Perry Homes
					name = @"Bob Perry";
				else if ([[name uppercaseString] hasPrefix:@"HUMAN RIGHTS CAMPAIGN TEXAS FAMILIES"])
					name = @"HRC TEXAS FAMILIES PAC";
				else if ([[name uppercaseString] hasPrefix:@"TEXANS FOR RICK PERRY"])
					name = @"RICK PERRY";
				NSString *nameSearch = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
				cellInfo.entryValue = nameSearch;
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryEntitySearch];
			}
			[thisSection addObject:cellInfo];
			[cellInfo release];
		}
		
		[self.sectionList addObject:thisSection];
		[thisSection release];
		
	}
	else if (([self.queryType integerValue] == kContributionQueryTop10Donors) ||
		([self.queryType integerValue] == kContributionQueryTop10Recipients)) {
		NSArray *jsonArray = jsonDeserialized;	
		
		// only one section right now
		[self.sectionList removeAllObjects];
		
		NSMutableArray *thisSection = [[NSMutableArray alloc] init];
		
		for (NSDictionary *dict in jsonArray) {
			double tempDouble = [[dict objectForKey:@"total_amount"] doubleValue];
			NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
			
			TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
			NSString *name = [[dict objectForKey:@"name"] capitalizedString];

			id dataID = [dict objectForKey:@"id"];
			
			cellInfo.title = name;
			cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = dataID;
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = YES;
			cellInfo.parameter = self.queryCycle;
			if ([self.queryType integerValue] == kContributionQueryTop10Donors)
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryDonor];
			else
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryRecipient];
			
			if (!dataID || [[NSNull null] isEqual:dataID] || ![dataID isKindOfClass:[NSString class]]) {
				NSLog(@"ERROR - Contribution results have an empty entity ID for: %@", name);								
				if ([[name uppercaseString] isEqualToString:@"BOB PERRY HOMES"])	// ala Bob Perry Homes
					name = @"Perry Homes";
				else if ([[name uppercaseString] hasPrefix:@"BOB PERRY"])	// ala Bob Perry Homes
					name = @"Bob Perry";
				else if ([[name uppercaseString] hasPrefix:@"HUMAN RIGHTS CAMPAIGN TEXAS FAMILIES"])
					name = @"HRC TEXAS FAMILIES PAC";
				else if ([[name uppercaseString] hasPrefix:@"TEXANS FOR RICK PERRY"])
					name = @"RICK PERRY";
				
				NSString *nameSearch = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
				cellInfo.entryValue = nameSearch;
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryEntitySearch];
			}
			[thisSection addObject:cellInfo];
			[cellInfo release];
		}
		
		[self.sectionList addObject:thisSection];
		[thisSection release];
		
	}
	else if ([self.queryType integerValue] == kContributionQueryRecipient ||
			 [self.queryType integerValue] == kContributionQueryDonor ||
			 [self.queryType integerValue] == kContributionQueryIndividual )
	{
		NSDictionary *jsonDict = jsonDeserialized;

		[self.sectionList removeAllObjects];
		NSMutableArray *thisSection = nil;
		
		NSDictionary *totals = [jsonDict objectForKey:@"totals"];
		NSArray *yearKeys = [totals allKeys]; 
		yearKeys = [yearKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		
		TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
		cellInfo.title = [[jsonDict objectForKey:@"name"] capitalizedString];
		cellInfo.subtitle = [[jsonDict objectForKey:@"type"] capitalizedString];
		cellInfo.entryValue = [jsonDict objectForKey:@"id"];
		cellInfo.entryType = [self.queryType integerValue];
 		cellInfo.isClickable = NO;
		cellInfo.action = nil;
		cellInfo.parameter = self.queryCycle;
		
		thisSection = [NSMutableArray arrayWithObject:cellInfo];
		[self.sectionList addObject:thisSection];
		[cellInfo release];
		
		thisSection = [[NSMutableArray alloc] init];
		NSString *amountKey = ([self.queryType integerValue] == kContributionQueryRecipient) ? @"recipient_amount" : @"contributor_amount";

		for (NSString *yearKey in [yearKeys reverseObjectEnumerator]) {			
			NSDictionary *dict = [totals objectForKey:yearKey];
			
			double tempDouble = [[dict objectForKey:amountKey] doubleValue];
			NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
			
			cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.subtitle = yearKey;
			cellInfo.title = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = [jsonDict objectForKey:@"id"];
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = YES;
			cellInfo.parameter = yearKey;
			
			if ([self.queryType integerValue] == kContributionQueryRecipient)
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryTop10Donors];
			else if ([self.queryType integerValue] == kContributionQueryIndividual)
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryTop10RecipientsIndiv];
			else
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryTop10Recipients];
			
			if ([yearKey isEqualToString:@"-1"]) {
				cellInfo.subtitle = NSLocalizedStringFromTable(@"Total", @"DataTableUI", @"Total contributions for a political campaign");
				//cellInfo.entryType = kContributionTotal;
				//cellInfo.isClickable = NO;
			}

			[thisSection addObject:cellInfo];
			[cellInfo release];
		}
		
		[self.sectionList addObject:thisSection];
		[thisSection release];
	}
	
	[numberFormatter release];
	[pool drain];
}


#pragma mark -
#pragma mark Data Object Methods

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath)
		return nil;
	
	id tempEntry = nil;
	NSArray *group = [self.sectionList objectAtIndex:indexPath.section];
	if (group && [group count] > indexPath.row)
		tempEntry = [group objectAtIndex:indexPath.row];
		return tempEntry;
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	if (!dataObject)
		return nil;
	
	NSInteger section = 0, row = 0;
	for (NSArray *group in self.sectionList) {
		for (id object in group) {
			if ([object isEqual:dataObject])
				return [NSIndexPath indexPathForRow:row inSection:section];
			row++;
		}
		section++;
	}
	return nil;
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"ContributionsDataSource - Error loading from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kContributionsDataNotifyError object:nil];
	}
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  

		id jsonDeserialized = [response.body mutableObjectFromJSONDataWithParseOptions:(JKParseOptionUnicodeNewlines & JKParseOptionLooseUnicode)];
		if (IsEmpty(jsonDeserialized))
			return;
		
		[self parseJSONObject:jsonDeserialized];
		[[NSNotificationCenter defaultCenter] postNotificationName:kContributionsDataNotifyLoaded object:self];
	}
}


@end
