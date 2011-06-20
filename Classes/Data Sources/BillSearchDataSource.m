//
//  BillSearchViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillSearchDataSource.h"
#import "TexLegeReachability.h"
#import "TexLegeTheme.h"
#import "TexLegeStandardGroupCell.h"
#import "BillMetadataLoader.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeLibrary.h"
#import "UtilityMethods.h"
#import "OpenLegislativeAPIs.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "LocalyticsSession.h"
#import "LoadingCell.h"
#import "StateMetaLoader.h"

#warning state specific

@implementation BillSearchDataSource
@synthesize searchDisplayController, delegateTVC;
@synthesize useLoadingDataCell;

- (id)init {
	if ((self=[super init])) {
		loadingStatus = LOADING_IDLE;
		useLoadingDataCell = NO;

		[OpenLegislativeAPIs sharedOpenLegislativeAPIs];
		
		_rows = [[NSMutableArray alloc] init];
		_sections = [[NSMutableDictionary alloc] init];
		delegateTVC = nil;
		searchDisplayController = nil;
	}
	return self;
}

- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController {
	if ((self=[self init])) {
		if (newController) {
			searchDisplayController = [newController retain];
			searchDisplayController.searchResultsDataSource = self;
		}
	}
	return self;
}

- (id)initWithTableViewController:(UITableViewController *)newDelegate {
	if ((self=[self init])) {		
		if (newDelegate) {
			delegateTVC = [newDelegate retain];
		}
	}
	return self;
}

- (void)dealloc {
	self.searchDisplayController = nil;
	self.delegateTVC = nil;
	nice_release(_rows);
	nice_release(_sections);

	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	
 	[super dealloc];
}

// This is just a short cut, we wind up using this array several times.  Perhaps we should remember it instead of recreating?
- (NSArray *) billTypes {
	return [[_sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];	
}

// return the map at the index in the array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *bill = [[_sections valueForKey:[[self billTypes] objectAtIndex:indexPath.section]] 
								 objectAtIndex:indexPath.row];
	return bill;
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	if (dataObject && [dataObject isKindOfClass:[NSDictionary class]] && [dataObject objectForKey:@"bill_id"]) {
		NSString *typeString = billTypeStringFromBillID([dataObject objectForKey:@"bill_id"]);
		if (!IsEmpty(typeString)) {
			NSMutableArray *sectionRow = [_sections objectForKey:typeString];
			if (!IsEmpty(sectionRow)) {
				NSArray *sortedSections = [self billTypes];
				NSInteger section = [sortedSections indexOfObject:typeString];
				NSInteger row = [sectionRow indexOfObject:dataObject];
				return [NSIndexPath indexPathForRow:row inSection:section];
			}
		}
	}
	return nil;
}

- (void) generateSections {
	BOOL found = NO;
	[_sections removeAllObjects];
	
    // Loop through the bills and create our keys
    for (NSDictionary *bill in _rows)
    {				
		NSString *c = billTypeStringFromBillID([bill objectForKey:@"bill_id"]);
	
        found = NO;
        for (NSString *str in [_sections allKeys])
        {
            if ([str isEqualToString:c])
            {
                found = YES;
            }
        }
        if (!found)
        {
            [_sections setValue:[NSMutableArray array] forKey:c];
        }
    }	
	
	// Loop again and sort the bills into their respective keys
    for (NSDictionary *bill in _rows)
    {
		NSString *typeString = billTypeStringFromBillID([bill objectForKey:@"bill_id"]);
		if (!IsEmpty(typeString))
			[[_sections objectForKey:typeString] addObject:bill];
    }
	
	// Sort each section array
    for (NSString *key in [_sections allKeys])
    {
		[[_sections objectForKey:key] sortUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
			NSString *bill_id1 = [item1 objectForKey:@"bill_id"];
			NSString *bill_id2 = [item2 objectForKey:@"bill_id"];
			return [bill_id1 compare:bill_id2 options:NSNumericSearch];
		}];		
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (IsEmpty(_sections))
		return 1;
	return [[_sections allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{	
	if (IsEmpty(_sections) || IsEmpty([self billTypes]))
		return @"";
	
	NSString *billType = [[self billTypes] objectAtIndex:section];
	return [[[[[BillMetadataLoader sharedBillMetadataLoader] metadata] objectForKey:@"types"] 
							findWhereKeyPath:@"title" 
							equals:billType] objectForKey:@"titleLong"];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (IsEmpty(_sections) || IsEmpty([self billTypes]))
		return nil;
    return [self billTypes];
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	if (NO == IsEmpty(_sections))
		return [[_sections valueForKey:[[self billTypes] objectAtIndex:section]] count];
	else if (useLoadingDataCell && loadingStatus > LOADING_IDLE)
		return 1;
	else
		return 0;
}

- (void)configureCell:(TexLegeStandardGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
		
	// Configure the cell.
	//NSDictionary *bill = [_rows objectAtIndex:indexPath.row];
	NSDictionary *bill = [self dataObjectForIndexPath:indexPath];
	if (!bill || [[NSNull null] isEqual:bill])
		return;  // ?????
	
	NSString *bill_id = [bill objectForKey:@"bill_id"];
	NSString *bill_title = [bill objectForKey:@"title"];
	
	bill_title = [bill_title chopPrefix:@"Relating to " capitalizingFirst:YES];
	
	cell.textLabel.text = bill_id;
	cell.detailTextLabel.text = bill_title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (useLoadingDataCell && loadingStatus > LOADING_IDLE) {
		if (indexPath.row == 0) {
			return [LoadingCell loadingCellWithStatus:loadingStatus tableView:tableView];
		}
		else {	// to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}
	
	NSString *CellIdentifier = @"CellOn";
	
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:CellIdentifier] autorelease];

		cell.textLabel.textColor = [TexLegeTheme textDark];
		cell.detailTextLabel.textColor = [TexLegeTheme indexText];
		cell.textLabel.font = [TexLegeTheme boldFifteen];
				
		if ([CellIdentifier isEqualToString:@"CellOff"]) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
    }
	if (NO == IsEmpty(_rows))
		[self configureCell:cell atIndexPath:indexPath];		

	return cell;
}

#pragma mark - Searching

// This is the standard search method ... fill in the search parameters and it'll handle the rest.
- (RKRequest *)startSearchWithQueryString:(NSString *)queryString params:(NSDictionary *)queryParams {
	if (IsEmpty(queryParams) || IsEmpty(queryString))
		return nil;
		
	RKRequest *request = nil;
	
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:osApiBaseURL] alert:YES])
	{		
		if (useLoadingDataCell)
			loadingStatus = LOADING_ACTIVE;
		
		OpenLegislativeAPIs *api = [OpenLegislativeAPIs sharedOpenLegislativeAPIs];
		request = [[api osApiClient] get:queryString queryParams:queryParams delegate:self];
	}
	else if (useLoadingDataCell) {
		loadingStatus = LOADING_NO_NET;
	}
	
	return request;
}

- (void)startSearchForText:(NSString *)searchString chamber:(NSInteger)chamber
{
	searchString = [searchString uppercaseString];
	NSMutableString *queryString = [NSMutableString stringWithString:@"/bills"];
	
	BOOL isBillID = NO;
	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
	if (IsEmpty(meta.selectedState) || IsEmpty(meta.currentSession))
		return;
	
	for (NSDictionary *type in [[[BillMetadataLoader sharedBillMetadataLoader] metadata] objectForKey:kBillMetadataTypesKey]) {
		NSString *billType = [type objectForKey:kBillMetadataTitleKey];
	 
		if (billType && [searchString hasPrefix:billType]) {
			NSString *tail = [searchString substringFromIndex:[billType length]];
			if (tail) {
				tail = [tail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
				if ([tail integerValue] > 0) {
					isBillID = YES;
#warning state specific ID assumptions
					NSNumber *billNumber = [NSNumber numberWithInteger:[tail integerValue]];		// we specifically convolute this to ensure we're grabbing only the numerical of the string
					[queryString appendFormat:@"/%@/%@/%@%%20%@", meta.selectedState, meta.currentSession, billType, billNumber];
					
					break;
				}
			}			
		}
	}
	
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										@"session", @"search_window",
										meta.selectedState, @"state",
										osApiKeyValue, @"apikey",
										nil];
	
	NSString *chamberString = stringForChamber(chamber, TLReturnOpenStates);
	if (!IsEmpty(chamberString)) {
		[queryParams setObject:chamberString forKey:@"chamber"];
	}
	if (IsEmpty(searchString))
		searchString = @"";
	
	if (!isBillID){
		[queryParams setObject:searchString forKey:@"q"];
	}
	
	[self startSearchWithQueryString:queryString params:queryParams];
		
}

- (void)startSearchForSubject:(NSString *)searchSubject chamber:(NSInteger)chamber {
	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
	if (IsEmpty(meta.selectedState))
		return;
	
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"session", @"search_window",
								 meta.selectedState, @"state",
								 osApiKeyValue, @"apikey",
								 nil];
	
	NSString *chamberString = stringForChamber(chamber, TLReturnOpenStates);
	if (!IsEmpty(chamberString)) {
		[queryParams setObject:chamberString forKey:@"chamber"];
	}
	if (IsEmpty(searchSubject))
		searchSubject = @"";
	else {
		NSDictionary *tagSubject = [NSDictionary dictionaryWithObject:searchSubject forKey:@"subject"];
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"BILL_SUBJECTS" attributes:tagSubject];	
	}
	[queryParams setObject:searchSubject forKey:@"subject"];
				
	[self startSearchWithQueryString:@"/bills" params:queryParams];
}

- (void)startSearchForBillsAuthoredBy:(NSString *)searchSponsorID {
	if (NO == IsEmpty(searchSponsorID)) {
		StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
		if (IsEmpty(meta.selectedState))
			return;
		
		NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
									 searchSponsorID, @"sponsor_id",
									 meta.selectedState, @"state",
									 @"session", @"search_window",
									 osApiKeyValue, @"apikey",
									 // now for the fun part
									 @"sponsors,bill_id,title,session,state,type,update_at,subjects", @"fields",
									 nil];

		RKRequest *request = [self startSearchWithQueryString:@"/bills" params:queryParams];
		if (request) {
			request.userData = [NSDictionary dictionaryWithObjectsAndKeys:
								searchSponsorID, @"sponsor_id", nil];
		}
		
	}
}

- (void)pruneBillsForAuthor:(NSString *)sponsorID {
	// We must be requesting specific bills for a given sponsors
	debug_NSLog(@"Pruning the list of sought-after bills for a given sponsor...");

	NSArray *tempRows = [[NSArray alloc] initWithArray:_rows];
	
	for (NSDictionary *bill in tempRows) {
		BOOL found = NO;
		BOOL hasSponsors = NO;
		
		for (NSDictionary *sponsor in [bill valueForKey:@"sponsors"]) {
			hasSponsors = YES;
			
			NSString *type = [sponsor valueForKey:@"type"];
			NSString *sponID = [sponsor valueForKey:@"leg_id"];
			if (NO == IsEmpty(type) && NO == IsEmpty(sponID)) {
				if ([type isEqualToString:@"author"] && [sponID isEqualToString:sponsorID]) {
					found = YES;
				}
			}
		}
		if (YES == hasSponsors && NO == found) {
			//debug_NSLog(@"Pruning bill %@ for %@", [bill valueForKey:@"bill_id"], sponsorID);
			[_rows removeObject:bill];
		}
	}
	[tempRows release];
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
	}	
	
	if (useLoadingDataCell)
		loadingStatus = LOADING_NO_NET;

	[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataError object:self];

	UIAlertView *alert = [[ UIAlertView alloc ] 
						   initWithTitle:NSLocalizedStringFromTable(@"Network Error", @"AppAlerts", @"Title for alert stating there's been an error when connecting to a server")
						   message:NSLocalizedStringFromTable(@"There was an error while contacting the server for bill information.  Please check your network connectivity or try again.", @"AppAlerts", @"")
						   delegate:nil // we're static, so don't do "self"
						   cancelButtonTitle: NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button cancelling some activity")
						   otherButtonTitles:nil];
	[ alert show ];	
	[ alert release];
	
}

// Handling GET /BillMetadata.json  
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if (useLoadingDataCell)
		loadingStatus = LOADING_NO_NET;

	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		if (useLoadingDataCell)
			loadingStatus = LOADING_IDLE;

		[_rows removeAllObjects];	
				
		id results = [response.body mutableObjectFromJSONData];
		if ([results isKindOfClass:[NSMutableArray class]])
			[_rows addObjectsFromArray:results];
		else if ([results isKindOfClass:[NSMutableDictionary class]])
			[_rows addObject:results];

		// if we wanted blocks, we'd do this instead:
		[_rows sortUsingComparator:^(NSMutableDictionary *item1, NSMutableDictionary *item2) {
			NSString *bill_id1 = [item1 objectForKey:@"bill_id"];
			NSString *bill_id2 = [item2 objectForKey:@"bill_id"];
			return [bill_id1 compare:bill_id2 options:NSNumericSearch];
		}];
		
		if (request.userData) {
		
			NSString *sponsorID = [request.userData objectForKey:@"sponsor_id"];
			if (NO == IsEmpty(sponsorID)) {
				// We must be requesting specific bills for a given sponsors			
				[self pruneBillsForAuthor:sponsorID];
			}
		}
				
		[self generateSections];
		
		if (searchDisplayController)
			[self.searchDisplayController.searchResultsTableView reloadData];
		else if (delegateTVC)
			[delegateTVC.tableView reloadData];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataLoaded object:self];
	}
}

@end


