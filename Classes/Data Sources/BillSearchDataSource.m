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
#import "DisclosureQuartzView.h"
#import "BillMetadataLoader.h"
#import "OpenLegislativeAPIs.h"
#import "TexLegeLibrary.h"
#import "UtilityMethods.h"
#import "OpenLegislativeAPIs.h"

#if	DISABLE_PRE_iOS4_SUPPORT
@interface NSDictionary (BillIDComparison)
- (NSComparisonResult)compareBillsByID:(NSDictionary *)p;
@end
@implementation NSDictionary (BillIDComparison)
- (NSComparisonResult)compareBillsByID:(NSDictionary *)p
{	
	return [[self objectForKey:@"bill_id"] compare: [p objectForKey:@"bill_id"] options:NSNumericSearch];	
}
@end
#endif

@implementation BillSearchDataSource
@synthesize searchDisplayController, delegateTVC;

- (id)init {
	if (self=[super init]) {
		[OpenLegislativeAPIs sharedOpenLegislativeAPIs];
		_rows = [[NSMutableArray alloc] init];
		delegateTVC = nil;
		searchDisplayController = nil;
	}
	return self;
}

- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController {
	if (self=[self init]) {
		if (newController) {
			searchDisplayController = [newController retain];
			searchDisplayController.searchResultsDataSource = self;
		}
	}
	return self;
}

- (id)initWithTableViewController:(UITableViewController *)newDelegate {
	if (self=[self init]) {		
		if (newDelegate) {
			delegateTVC = [newDelegate retain];
		}
	}
	return self;
}

- (void)dealloc {
	[searchDisplayController release];
	[delegateTVC release];
	[_rows release];
	_rows = nil;

	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	
 	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [_rows count];
}

/* Build a list of files */
- (NSArray *)billResults {
	return _rows;
}

// return the map at the index in the array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	return [self.billResults objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	return [NSIndexPath indexPathForRow:[_rows indexOfObject:dataObject] inSection:0];	
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
		
	// Configure the cell.
	NSDictionary *bill = [_rows objectAtIndex:indexPath.row];
	NSString *bill_id = [bill objectForKey:@"bill_id"];
	NSString *bill_title = [bill objectForKey:@"title"];
	if (!bill_title)
		bill_title = @"";
	
	cell.textLabel.text = bill_id;
	cell.detailTextLabel.text = bill_title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = @"CellOn";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:CellIdentifier] autorelease];
		
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		
		if ([CellIdentifier isEqualToString:@"CellOff"])
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		else {
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			cell.textLabel.minimumFontSize = 12.0f;
			DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
			cell.accessoryView = qv;
			[qv release];			
		}
    }
		
	if (!IsEmpty(_rows))
		[self configureCell:cell atIndexPath:indexPath];		

	return cell;
}

- (void)startSearchWithString:(NSString *)searchString chamber:(NSInteger)chamber
{
	searchString = [searchString uppercaseString];
	NSMutableString *queryString = [NSMutableString stringWithString:@"/bills"];
	
	BOOL isBillID = NO;
	
	for (NSDictionary *type in [[[BillMetadataLoader sharedBillMetadataLoader] metadata] objectForKey:kBillMetadataTypesKey]) {
		NSString *billType = [type objectForKey:kBillMetadataTitleKey];
	 
		if (billType && [searchString hasPrefix:billType]) {
			NSString *tail = [searchString substringFromIndex:[billType length]];
			if (tail) {
				tail = [tail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
				if ([tail integerValue] > 0) {
					isBillID = YES;
					NSNumber *billNumber = [NSNumber numberWithInteger:[tail integerValue]];		// we specifically convolute this to ensure we're grabbing only the numerical of the string
					
					NSString *billSession = @"82";
#warning hard coded session
					[queryString appendFormat:@"/tx/%@/%@%%20%@", billSession, billType, billNumber];
					
					break;
				}
			}			
		}
	}
	
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										@"session", @"search_window",
										@"tx", @"state",
										osApiKeyValue, osApiKeyKey,
										nil];
	
	NSString *chamberString = stringForChamber(chamber, TLReturnOpenstatesShort);
	if (!IsEmpty(chamberString)) {
		[queryParams setObject:chamberString forKey:@"chamber"];
	}
	if (IsEmpty(searchString))
		searchString = @"";
	
	if (!isBillID){
		[queryParams setObject:searchString forKey:@"q"];
	}
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:osApiBaseURL] alert:YES])
		[[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient] get:queryString queryParams:queryParams delegate:self];
	
}

- (void)startSearchForSubject:(NSString *)searchSubject chamber:(NSInteger)chamber {
	NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"session", @"search_window",
								 @"tx", @"state",
								 osApiKeyValue, osApiKeyKey,
								 nil];
	
	NSString *chamberString = stringForChamber(chamber, TLReturnOpenstatesShort);
	if (!IsEmpty(chamberString)) {
		[queryParams setObject:chamberString forKey:@"chamber"];
	}
	if (IsEmpty(searchSubject))
		searchSubject = @"";
	
	[queryParams setObject:searchSubject forKey:@"subject"];
			
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:osApiBaseURL] alert:YES])
		[[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] osApiClient] get:@"/bills" queryParams:queryParams delegate:self];
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataError object:nil];
	}
}


// Handling GET /BillMetadata.json  
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		[_rows removeAllObjects];	
		
		id results = [response bodyAsJSON];
		if ([results isKindOfClass:[NSArray class]])
			[_rows addObjectsFromArray:results];
		else if ([results isKindOfClass:[NSDictionary class]])
			[_rows addObject:results];

#if	DISABLE_PRE_iOS4_SUPPORT
		// if we wanted blocks, we'd do this instead:
		[_rows sortUsingComparator:^(NSDictionary *item1, NSDictionary *item2) {
			NSString *bill_id1 = [item1 objectForKey:@"bill_id"];
			NSString *bill_id2 = [item2 objectForKey:@"bill_id"];
			return [bill_id1 compare:bill_id2 options:NSNumericSearch];
		}];
#else
		[_rows sortUsingSelector:@selector(compareBillsByID:)];
#endif
		
		if (searchDisplayController)
			[self.searchDisplayController.searchResultsTableView reloadData];
		else if (delegateTVC)
			[delegateTVC.tableView reloadData];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBillSearchNotifyDataLoaded object:nil];
	}
}

@end


