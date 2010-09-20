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

#import "TexLegeStandardGroupCell.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"

#import "JSON.h"

static const NSString *apiKey = @"apikey=350284d0c6af453b9b56f6c1c7fea1f9";

@interface LegislatorContributionsDataSource(Private)
- (void)createSectionWithData:(NSData *)jsonData;
- (void)parseJSONObject:(id)jsonDeserialized;
- (void)establishConnectionWithURL:(NSURL *)url;
@end


@implementation LegislatorContributionsDataSource
@synthesize sectionList, queryEntityID, queryType, queryCycle, urlConnection, receivedData;

- (NSString *)title {
	NSString *title = nil;
	if ([self.queryType integerValue] == kContributionQueryTop10Donors)
		title = @"Top Contributions";
	else if ([self.queryType integerValue] == kContributionQueryTop10Recipients || [self.queryType integerValue] == kContributionQueryTop10RecipientsIndiv)
		title = @"Top Recipients";
	else if ([self.queryType integerValue] == kContributionQueryRecipient)
		title = @"Recipient Details";
	else if ([self.queryType integerValue] == kContributionQueryDonor || [self.queryType integerValue] == kContributionQueryIndividual)
		title = @"Contributor Details";
	else if ([self.queryType integerValue] == kContributionQueryEntitySearch)
		title = @"Entity Search";
	
	if (self.queryCycle && [self.queryCycle length]) {
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
	[self.urlConnection cancel];
	self.urlConnection = nil;
	self.receivedData = nil;
	self.queryType = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark URL Connection

- (void)initiateQueryWithQueryID:(NSString *)aQuery type:(NSNumber *)type cycle:(NSString *)cycle {
	self.queryEntityID = aQuery;
	self.queryType = type;
	self.queryCycle = cycle;
	
	NSString *urlMethod = nil;
	NSString *urlRoot = @"http://transparencydata.com/api/1.0";
	//NSString *memberID = self.legislator.transDataContributorID;
	if ([self.queryType integerValue] == kContributionQueryTop10Donors) {
		// http://transparencydata.com/api/1.0/aggregates/pol/7c299471e4414887acc94f98785a90b0/contributors.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9
		urlMethod = [NSString stringWithFormat:@"/aggregates/pol/%@/contributors.json?cycle=%@&%@", aQuery, self.queryCycle, apiKey];	
	}
	else if ([self.queryType integerValue] == kContributionQueryTop10RecipientsIndiv) {
		// http://transparencydata.com/api/1.0/aggregates/pol/7c299471e4414887acc94f98785a90b0/contributors.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9
		urlMethod = [NSString stringWithFormat:@"/aggregates/indiv/%@/recipient_pols.json?cycle=%@&%@", aQuery, self.queryCycle, apiKey];	
	}
	else if ([self.queryType integerValue] == kContributionQueryTop10Recipients) {
		//urlMethod = [NSString stringWithFormat:@"/aggregates/indiv/%@/recipient_pols.json?cycle=%@&%@", aQuery, self.queryCycle, apiKey];	
		urlMethod = [NSString stringWithFormat:@"/aggregates/org/%@/recipients.json?cycle=%@&%@", aQuery, self.queryCycle, apiKey];			
	}
	else if ([self.queryType integerValue] == kContributionQueryRecipient ||
			 [self.queryType integerValue] == kContributionQueryDonor ||
			 [self.queryType integerValue] == kContributionQueryIndividual) {
		// http://transparencydata.com/api/1.0/entities/7c299471e4414887acc94f98785a90b0.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9
		urlMethod = [NSString stringWithFormat:@"/entities/%@.json?cycle=%@&%@", aQuery, self.queryCycle, apiKey];	
	}
	else if ([self.queryType integerValue] == kContributionQueryEntitySearch) {
		urlMethod = [NSString stringWithFormat:@"/entities.json?search=%@&%@", aQuery, apiKey];
	}
	NSString *urlString = [urlRoot stringByAppendingString:urlMethod];
	
	debug_NSLog(@"Contributions URL: %@", urlString);
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	if ([UtilityMethods canReachHostWithURL:url alert:YES]) {
		[self establishConnectionWithURL:url];
	}
}



- (void)establishConnectionWithURL:(NSURL *)url {
	// Create the request.
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:15.0];
	self.urlConnection = nil;
	self.urlConnection =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (self.urlConnection) {
		self.receivedData = [NSMutableData data];
	} else {
		// Inform the user that the connection failed.
		debug_NSLog(@"Could not establish a connection to the url: %@", url);
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    self.receivedData = nil;
	
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *jsonString = [[NSString alloc] initWithBytes:self.receivedData.bytes length:self.receivedData.length encoding:NSUTF8StringEncoding];	
	id jsonDeserialized = [jsonString JSONValue];
	[jsonString release];
	[connection release];
	self.receivedData = nil;
	
	[self parseJSONObject:jsonDeserialized];
}

- (void)parseJSONObject:(id)jsonDeserialized {
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
			NSString *entityType = [[dict objectForKey:@"type"] capitalizedString];
			//NSString *valueKey = @"";
			NSNumber *action = nil;
			if ([entityType isEqualToString:@"Politician"]) {
				//valueKey = @"total_received";
				action = [NSNumber numberWithInteger:kContributionQueryRecipient];
			}
			else if ([entityType isEqualToString:@"Organization"]) {
				//valueKey = @"total_given";
				action = [NSNumber numberWithInteger:kContributionQueryDonor];
			}
			else if ([entityType isEqualToString:@"Individual"]) {
				//valueKey = @"total_given";
				action = [NSNumber numberWithInteger:kContributionQueryIndividual];
			}
			
			
			//double tempDouble = [[dict objectForKey:valueKey] doubleValue];
			//NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
			
			TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.title = [dict valueForKey:@"name"];
			cellInfo.subtitle = entityType;
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
			cellInfo.subtitle = @"Nothing for";
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
			
			cellInfo.title = name;
			cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = [dict objectForKey:@"recipient_entity"];
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = YES;
			cellInfo.parameter = self.queryCycle;
			cellInfo.action = [NSNumber numberWithInteger:kContributionQueryRecipient];
			
			
			if (!cellInfo.entryValue || ![cellInfo.entryValue length]) {	// we didn't receive an ID!!!
				if ([[name uppercaseString] isEqualToString:@"BOB PERRY HOMES"])	// ala Bob Perry Homes
					name = @"Perry Homes";
				else if ([[name uppercaseString] hasPrefix:@"BOB PERRY"])	// ala Bob Perry Homes
					name = @"Bob Perry";
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

			cellInfo.title = name;
			cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = [dict objectForKey:@"id"];
			cellInfo.entryType = [self.queryType integerValue];
			cellInfo.isClickable = YES;
			cellInfo.parameter = self.queryCycle;
			if ([self.queryType integerValue] == kContributionQueryTop10Donors)
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryDonor];
			else
				cellInfo.action = [NSNumber numberWithInteger:kContributionQueryRecipient];
			
			
			if (!cellInfo.entryValue || ![cellInfo.entryValue length]) {	// we didn't receive an ID!!!
				if ([[name uppercaseString] isEqualToString:@"BOB PERRY HOMES"])	// ala Bob Perry Homes
					name = @"Perry Homes";
				else if ([[name uppercaseString] hasPrefix:@"BOB PERRY"])	// ala Bob Perry Homes
					name = @"Bob Perry";
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
		
		// info and body
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
		
		/*if ([self.queryType integerValue]== kContributionQueryRecipient) {
			cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.subtitle = @"Total";
			cellInfo.title = @"Top 10 Contributors";
			cellInfo.entryValue = [jsonDict objectForKey:@"id"];
			cellInfo.entryType = kContributionQueryTop10Contributors;
			cellInfo.isClickable = YES;
			thisSection = [NSMutableArray arrayWithObject:cellInfo];
			[self.sectionList addObject:thisSection];
			[cellInfo release];
		}
		*/		
		thisSection = [[NSMutableArray alloc] init];
		NSString *amountKey = ([self.queryType integerValue] == kContributionQueryRecipient) ? @"recipient_amount" : @"contributor_amount";
		//NSString *countKey = ([self.queryType integerValue] == kContributionQueryRecipient) ? @"recipient_count" : @"contributor_count";
		for (NSString *yearKey in [yearKeys reverseObjectEnumerator]) {			
			NSDictionary *dict = [totals objectForKey:yearKey];
			
			//NSNumber *numContribs = [dict objectForKey:countKey];
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
				cellInfo.subtitle = @"Total";
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
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kContributionsDataChangeNotificationKey object:self];

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
#pragma mark UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	NSInteger count = 0;
	if (self.sectionList)
		count = [self.sectionList count];
	return count;
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
	NSString *title = @"Contributions";
	
	switch ([self.queryType integerValue]) {
		case kContributionQueryRecipient: {
			switch (section) {
				case 0:
					title = @"Recipient Information";
					break;
				case 1:
/*					title = @"Contributor Details";
					break;
				case 2:
*/				default:
					title = @"Aggregate Contributions";
					break;
			}
		}
			break;
		case kContributionQueryDonor: 
		case kContributionQueryIndividual:
		{
			switch (section) {
				case 0:
					title = @"Contributor Information";
					break;
				case 1:
					title = @"Contributions (to everyone)";
					break;
			}
		}
			break;
		case kContributionQueryTop10Donors:
			title = @"Biggest Contributors";
			break;
		case kContributionQueryTop10Recipients:
		case kContributionQueryTop10RecipientsIndiv:
			title = @"Biggest Recipients";
			break;
		case kContributionQueryEntitySearch:
			title = @"Entity Search Results";
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
		debug_NSLog(@"LegislatorContributionsDataSource:cellForRow: error finding table entry for section:%d row:%d", indexPath.section, indexPath.row);
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


@end
