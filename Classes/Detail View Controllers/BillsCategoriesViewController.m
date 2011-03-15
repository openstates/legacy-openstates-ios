//
//  BillsCategoriesViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "TexLegeAppDelegate.h"
#import "BillsCategoriesViewController.h"
#import "BillsDetailViewController.h"
#import "JSON.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "TexLegeReachability.h"
#import "TexLegeCoreDataUtils.h"
#import "BillsListDetailViewController.h"
#import "BillSearchDataSource.h"

@interface BillsCategoriesViewController (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//- (NSString *)watchIDForBill:(NSDictionary *)aBill;
@end

@implementation BillsCategoriesViewController


#pragma mark -
#pragma mark View lifecycle

/*
 - (void)didReceiveMemoryWarning {
 [_cachedBills release];
 _cachedBills = nil;	
 }*/

- (void)viewDidLoad {
	[super viewDidLoad];
/*	
	if (!_requestDictionary)
		_requestDictionary = [[[NSMutableDictionary alloc] init] retain];
	
	if (!_requestSenders)
		_requestSenders = [[[NSMutableDictionary alloc] init] retain];	
*/		
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = [[self class] description];
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];

	//	[[self navigationItem] setRightBarButtonItem:[self editButtonItem] animated:YES];
	
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	
	[self refreshCategories:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (![TexLegeReachability canReachHostWithURL:[NSURL URLWithString:@"http://openstates.sunlightlabs.com"] alert:YES])
		return;
			
	[self.tableView reloadData];
}

/*- (void)viewWillDisappear:(BOOL)animated {
 //	[self save:nil];
 [super viewWillDisappear:animated];
 }*/

- (IBAction)refreshCategories:(id)sender {
	if (_CategoriesList)
		[_CategoriesList release], _CategoriesList = nil;	
	
	NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillCategoriesFile];
	NSString *remotePath = [NSString stringWithFormat:@"%@/%@", RESTKIT_BASE_URL, kBillCategoriesFile];
	
	NSURL *categoriesURL = [NSURL URLWithString:remotePath];
	if ([TexLegeReachability canReachHostWithURL:categoriesURL alert:NO]){
		NSError *error = nil;
		NSString *jsonMenus = [NSString stringWithContentsOfURL:categoriesURL encoding:NSUTF8StringEncoding error:&error];
		NSDictionary *metaData = [jsonMenus JSONValue];
		if (metaData) {
			[metaData writeToFile:localPath atomically:YES];	
			_CategoriesList = [[metaData objectForKey:@"subjects"] retain];
		}		
	}
	if (!_CategoriesList) {	// let's try the one we have stored
		NSError *error = nil;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:localPath]) {
			NSString *defaultPath = [[NSBundle mainBundle] pathForResource:kBillCategoriesPath ofType:@"json"];
			[fileManager copyItemAtPath:defaultPath toPath:localPath error:&error];
		}
		NSString *jsonMenus = [NSString stringWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:&error];
		NSDictionary *metaData = [jsonMenus JSONValue];
		if (metaData)
			_CategoriesList = [[metaData objectForKey:@"subjects"] retain];
	}
	if (_CategoriesList && [_CategoriesList count]) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		[_CategoriesList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];	
	}	
	[self.tableView reloadData];
}
/*
- (IBAction)refreshBill:(NSDictionary *)watchedItem sender:(id)sender {
	NSString *queryString = [NSString stringWithFormat:@"http://openstates.sunlightlabs.com/api/v1/bills/tx/%@/%@/?apikey=350284d0c6af453b9b56f6c1c7fea1f9", 
							 [watchedItem objectForKey:@"session"], [[watchedItem objectForKey:@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[self JSONRequestWithURLString:queryString sender:sender];
}
*/

- (void)viewDidUnload {
/*	[_requestDictionary release];
	_requestDictionary = nil;
	[_requestSenders release];
	_requestSenders = nil;
*/
	[_CategoriesList release];
	_CategoriesList = nil;
	[super viewDidUnload];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	cell.textLabel.text = [[_CategoriesList objectAtIndex:indexPath.row] objectForKey:@"title"];
}

#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_CategoriesList && [_CategoriesList count])
		return [_CategoriesList count];
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = @"CellOn";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
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
	
	if (_CategoriesList && [_CategoriesList count])
		[self configureCell:cell atIndexPath:indexPath];		
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (!_CategoriesList)
		return;
	
	NSDictionary *item = [_CategoriesList objectAtIndex:indexPath.row];
	if (item && [item objectForKey:@"title"]) {
		NSString *cat = [item objectForKey:@"title"];
		if (cat) {
			//BOOL changingViews = NO;
			BillsListDetailViewController *catResultsView = [[[BillsListDetailViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
			BillSearchDataSource *dataSource = [catResultsView valueForKey:@"dataSource"];
			catResultsView.title = cat;
			//[dataSource startSearchWithString:cat chamber:0];
			[dataSource startSearchForSubject:cat chamber:BOTH_CHAMBERS];
			
			[self.navigationController pushViewController:catResultsView animated:YES];

			/*
			BillsDetailViewController *detailView = nil;
			if ([UtilityMethods isIPadDevice]) {
				id aDetail = [[[TexLegeAppDelegate appDelegate] detailNavigationController] visibleViewController];
				if ([aDetail isKindOfClass:[BillsDetailViewController class]])
					detailView = aDetail;
			}
			if (!detailView) {
				detailView = [[[BillsDetailViewController alloc] 
							   initWithNibName:@"BillsDetailViewController" bundle:nil] autorelease];
				changingViews = YES;
			}
			
			[detailView setDataObject:bill];
			if (![UtilityMethods isIPadDevice])
				[self.navigationController pushViewController:detailView animated:YES];
			else if (changingViews)
				[[[TexLegeAppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:detailView] animated:NO];
*/
		}			
	}
}

- (void)dealloc {	
	
	if (_CategoriesList) {
		[_CategoriesList release];
		_CategoriesList = nil;
	}
	/*
	if (_cachedBills) {
		[_cachedBills release];
		_cachedBills = nil;
	}
	
	[_requestDictionary release];
	_requestDictionary = nil;
	[_requestSenders release];
	_requestSenders = nil;
	*/
	
	[super dealloc];
}
/*
- (void)JSONRequestWithURLString:(NSString *)queryString sender:(id)sender {
	//in the viewDidLoad
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:queryString]];
	NSURLConnection *newConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
	NSMutableData *data = [NSMutableData data];	
	[_requestDictionary setObject:data forKey:[newConnection description]];
	[_requestSenders setObject:sender forKey:[newConnection description]];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
    [[_requestDictionary objectForKey:[connection description]] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[_requestDictionary objectForKey:[connection description]] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
	if ([_requestDictionary objectForKey:[connection description]])
		[_requestDictionary removeObjectForKey:[connection description]];
	
	if ([_requestSenders objectForKey:[connection description]])
		[_requestSenders removeObjectForKey:[connection description]];
	
	/	if (connection) {
	 [connection release];
	 connection = nil;
	 }
	 *
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSMutableData *data = [_requestDictionary objectForKey:[connection description]];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	id sender = [_requestSenders objectForKey:[connection description]];
	id object = [responseString JSONValue];
	[responseString release];
	
	if (sender && object && _cachedBills) {
		NSString *watchID = [self watchIDForBill:object];
		[_cachedBills setObject:object forKey:watchID];
		
		NSInteger row = NSNotFound;
		if ([sender isKindOfClass:[NSDictionary class]])
			row = [_watchList indexOfObject:sender];
		else {
			NSInteger index = 0;
			for (NSDictionary *search in _watchList) {
				if ([[search objectForKey:@"watchID"] isEqualToString:watchID]) {
					row = index;
					break;
				}
				index++;
			}
		}
		if (row == NSNotFound)
			row = 0;
		NSIndexPath *rowPath = [NSIndexPath indexPathForRow:row inSection:0];
		//[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:rowPath] withRowAnimation:UITableViewRowAnimationMiddle];
		if (row+1 > [_watchList count])
			[self.tableView reloadData];
		else
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:rowPath] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	if ([_requestDictionary objectForKey:[connection description]])
		[_requestDictionary removeObjectForKey:[connection description]];
	if ([_requestSenders objectForKey:[connection description]])
		[_requestSenders removeObjectForKey:[connection description]];
	
	/    [connection release];
	 connection = nil;
	 *
}
*/
@end


