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
- (void)initiateQueryWithQueryID:(NSString *)aQuery;
- (void)createSectionWithData:(NSData *)jsonData;
- (void)parseJSONObject:(id)jsonDeserialized;
- (void)establishConnectionWithURL:(NSURL *)url;
@end


@implementation LegislatorContributionsDataSource
@synthesize sectionList, queryEntityID, contributionQueryType, urlConnection, receivedData;

- (NSString *)title {
	NSString *title = nil;
	if ([self.contributionQueryType integerValue] == kContributionQueryTop20Contributors)
		title = @"Top 20 Contributors";
	else if ([self.contributionQueryType integerValue] == kContributionQueryRecipient)
		title = @"Contributions";
	else if ([self.contributionQueryType integerValue] == kContributionQueryDonor)
		title = @"Donor Details";
	return title;
}

- (void)setQueryEntityID:(NSString *)newObj {	
	if (queryEntityID) [queryEntityID release], queryEntityID = nil;
	if (newObj) {		
		queryEntityID = [newObj retain];		
		[self initiateQueryWithQueryID:queryEntityID];
	}
}

- (void)dealloc {
	self.sectionList = nil;
	self.queryEntityID = nil;
	[self.urlConnection cancel];
	self.urlConnection = nil;
	self.receivedData = nil;
	self.contributionQueryType = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark URL Connection

- (void)initiateQueryWithQueryID:(NSString *)aQuery {
	NSString *urlMethod = nil;
	NSString *urlRoot = @"http://transparencydata.com/api/1.0";
	//NSString *memberID = self.legislator.transDataContributorID;
	if ([self.contributionQueryType integerValue] == kContributionQueryTop20Contributors) {
		// http://transparencydata.com/api/1.0/aggregates/pol/7c299471e4414887acc94f98785a90b0/contributors.json?limit=20&apikey=350284d0c6af453b9b56f6c1c7fea1f9
		urlMethod = [NSString stringWithFormat:@"/aggregates/pol/%@/contributors.json?limit=20&%@", aQuery, apiKey];	
	}
	else if ([self.contributionQueryType integerValue] == kContributionQueryRecipient ||
			 [self.contributionQueryType integerValue] == kContributionQueryDonor) {
		// http://transparencydata.com/api/1.0/entities/7c299471e4414887acc94f98785a90b0.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9
		urlMethod = [NSString stringWithFormat:@"/entities/%@.json?%@", aQuery, apiKey];	
	}
	NSString *urlString = [urlRoot stringByAppendingString:urlMethod];
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
	
	if ([self.contributionQueryType integerValue] == kContributionQueryTop20Contributors) {
		NSArray *jsonArray = jsonDeserialized;	
		
		// only one section right now
		[self.sectionList removeAllObjects];
		
		NSMutableArray *thisSection = [[NSMutableArray alloc] init];
		
		for (NSDictionary *dict in jsonArray) {
			double tempDouble = [[dict objectForKey:@"total_amount"] doubleValue];
			NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
			
			TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.title = [[dict objectForKey:@"name"] capitalizedString];
			cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = [dict objectForKey:@"id"];
			cellInfo.entryType = kContributionQueryDonor;
			cellInfo.isClickable = YES;
			
			[thisSection addObject:cellInfo];
			[cellInfo release];
		}
		
		[self.sectionList addObject:thisSection];
		[thisSection release];
		
	}
	else if ([self.contributionQueryType integerValue] == kContributionQueryRecipient ||
			 [self.contributionQueryType integerValue] == kContributionQueryDonor) {
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
		cellInfo.entryType = [self.contributionQueryType integerValue];
		cellInfo.isClickable = NO;
		thisSection = [NSMutableArray arrayWithObject:cellInfo];
		[self.sectionList addObject:thisSection];
		[cellInfo release];
		
		if ([self.contributionQueryType integerValue]== kContributionQueryRecipient) {
			cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.subtitle = @"Other";
			cellInfo.title = @"Top 20 Contributors";
			cellInfo.entryValue = [jsonDict objectForKey:@"id"];
			cellInfo.entryType = kContributionQueryTop20Contributors;
			cellInfo.isClickable = YES;
			thisSection = [NSMutableArray arrayWithObject:cellInfo];
			[self.sectionList addObject:thisSection];
			[cellInfo release];
		}
				
		thisSection = [[NSMutableArray alloc] init];
		NSString *amountKey = ([self.contributionQueryType integerValue] == kContributionQueryRecipient) ? @"recipient_amount" : @"contributor_amount";
		NSString *countKey = ([self.contributionQueryType integerValue] == kContributionQueryRecipient) ? @"recipient_count" : @"contributor_count";
		for (NSString *yearKey in [yearKeys reverseObjectEnumerator]) {			
			NSDictionary *dict = [totals objectForKey:yearKey];
			
			NSNumber *numContribs = [dict objectForKey:countKey];
			double tempDouble = [[dict objectForKey:amountKey] doubleValue];
			NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
			
			cellInfo = [[TableCellDataObject alloc] init];
			cellInfo.subtitle = yearKey;
			cellInfo.title = [numberFormatter stringFromNumber:amount];
			cellInfo.entryValue = numContribs; //[dict objectForKey:@"id"];
			cellInfo.entryType = [self.contributionQueryType integerValue];
			cellInfo.isClickable = NO;
			
			if ([yearKey isEqualToString:@"-1"]) {
				cellInfo.subtitle = @"Total";
				cellInfo.entryType = kContributionTotal;
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
	
	switch ([self.contributionQueryType integerValue]) {
		case kContributionQueryRecipient: {
			switch (section) {
				case 0:
					title = @"Candidate Information";
					break;
				case 1:
					title = @"Contributor Details";
					break;
				case 2:
				default:
					title = @"Aggregate Contributions";
					break;
			}
		}
			break;
		case kContributionQueryDonor: {
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
		case kContributionQueryTop20Contributors:
			title = @"Largest Donors";
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
		
		if ([self.contributionQueryType integerValue] == kContributionQueryTop20Contributors)
			style = UITableViewCellStyleValue1;
		else if (cellInfo.isClickable && [self.contributionQueryType integerValue] == kContributionQueryRecipient)
			style = [TexLegeStandardGroupCell cellStyle];
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
