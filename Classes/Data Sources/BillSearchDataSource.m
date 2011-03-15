//
//  BillSearchViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillSearchDataSource.h"
#import "JSON.h"
#import "TexLegeReachability.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"

@interface NSDictionary (BillIDComparison)
- (NSComparisonResult)compareBillsByID:(NSDictionary *)p;
@end
@implementation NSDictionary (BillIDComparison)
- (NSComparisonResult)compareBillsByID:(NSDictionary *)p
{	
	return [[self objectForKey:@"bill_id"] compare: [p objectForKey:@"bill_id"] options:NSNumericSearch];	
}
@end


@implementation BillSearchDataSource
@synthesize searchDisplayController, delegateTVC;

- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController; {
	if ([super init]) {
		_rows = [[NSMutableArray alloc] init];
		_activeConnection = nil;
		delegateTVC = nil;
		
		if (newController) {
			searchDisplayController = [newController retain];
			searchDisplayController.searchResultsDataSource = self;
		}
		
	}
	return self;
}

- (id)initWithTableViewController:(UITableViewController *)newDelegate; {
	if ([super init]) {
		_rows = [[NSMutableArray alloc] init];
		_activeConnection = nil;
		searchDisplayController = nil;
		
		if (newDelegate) {
			delegateTVC = [newDelegate retain];
		}
		
	}
	return self;
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
		
	if (_rows && [_rows count])
		[self configureCell:cell atIndexPath:indexPath];		

	return cell;
}

// #define TESTING_BILLSEARCH 1
#ifdef TESTING_BILLSEARCH

- (void)mockData:(NSTimer*)timer {
	[_rows removeAllObjects];
	int count = 1 + random() % 20;
	for (int i = 0; i < count; i++) {
		NSDictionary *fakeDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSString stringWithFormat:@"FAKE %d", i], @"bill_id",
								  timer.userInfo, @"title", nil];
		[_rows addObject:fakeDict];
	}
	if (searchDisplayController)
		[self.searchDisplayController.searchResultsTableView reloadData];
	else if (delegateTVC)
		[delegateTVC.tableView reloadData];
}
#endif

- (void)startSearchWithString:(NSString *)searchString chamber:(NSInteger)chamber
{
#ifndef TESTING_BILLSEARCH
	if (_activeConnection) {
		[_activeConnection cancel];
		[_activeConnection release];
		_activeConnection = nil;
	}
	
	//in the viewDidLoad
	if (_data) {
		[_data release];
		_data = nil;
	}
	
	_data = [[NSMutableData data] retain];
	NSString *baseurl = @"http://openstates.sunlightlabs.com/api/v1/bills/?search_window=session&state=tx&apikey=350284d0c6af453b9b56f6c1c7fea1f9";
	NSString *chamberString = @"";
	if (chamber == HOUSE)
		chamberString = @"&chamber=lower";
	else if (chamber == SENATE)
		chamberString = @"&chamber=upper";
	
	if (!searchString)
		searchString = @"";
	
	searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSString *endQuery = [NSString stringWithFormat:@"%@&q=%@", chamberString, searchString];
	NSString *queryString = [NSString stringWithFormat:@"%@%@", baseurl, endQuery];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString]];//asynchronous call

	if ([TexLegeReachability canReachHostWithURL:[request URL] alert:YES])
		_activeConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
#else
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(mockData:) userInfo:searchString repeats:NO];
#endif
}

- (void)startSearchForSubject:(NSString *)searchSubject chamber:(NSInteger)chamber {
	

#ifndef TESTING_BILLSEARCH
	if (_activeConnection) {
		[_activeConnection cancel];
		[_activeConnection release];
		_activeConnection = nil;
	}
	
	//in the viewDidLoad
	if (_data) {
		[_data release];
		_data = nil;
	}
	
	_data = [[NSMutableData data] retain];
	//http://openstates.sunlightlabs.com/api/v1/bills/?subject=Sexual%20Orientation%20and%20Gender%20Issues&state=tx&chamber=upper&apikey=350284d0c6af453b9b56f6c1c7fea1f9
	NSString *baseurl = @"http://openstates.sunlightlabs.com/api/v1/bills/?search_window=session&state=tx&apikey=350284d0c6af453b9b56f6c1c7fea1f9";
	//&search_window=session
	NSString *chamberString = @"";
	if (chamber == HOUSE)
		chamberString = @"&chamber=lower";
	else if (chamber == SENATE)
		chamberString = @"&chamber=upper";
	
	if (!searchSubject)
		searchSubject = @"";
	
	searchSubject = [searchSubject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *endQuery = [NSString stringWithFormat:@"%@&subject=%@", chamberString, searchSubject];
	NSString *queryString = [NSString stringWithFormat:@"%@%@", baseurl, endQuery];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString]];//asynchronous call
	
	if ([TexLegeReachability canReachHostWithURL:[request URL] alert:YES])
		_activeConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
#else
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(mockData:) userInfo:searchString repeats:NO];
#endif
	
}

- (void)dealloc {
	[searchDisplayController release];
	[delegateTVC release];
	[_rows release];
	_rows = nil;
	if (_data) {
		[_data release];
		_data = nil;
	}
	if (_activeConnection) {
		[_activeConnection cancel];
		[_activeConnection release];
		_activeConnection = nil;
	}
 	[super dealloc];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
	
	NSString *responseString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
	
	[_rows removeAllObjects];
	[_rows addObjectsFromArray:[responseString JSONValue]];
	[responseString release];
	
#if	0 //NS_BLOCKS_AVAILABLE
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
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    [_data release];
	_data = nil;
	
	[_rows removeAllObjects];
	[_rows addObjectsFromArray:[responseString JSONValue]];
	[responseString release];
    [connection release];

#if	0 //NS_BLOCKS_AVAILABLE
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
	
}

@end


