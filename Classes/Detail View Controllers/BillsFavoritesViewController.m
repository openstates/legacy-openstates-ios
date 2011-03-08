//
//  BillsFavoritesViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "TexLegeAppDelegate.h"
#import "BillsFavoritesViewController.h"
#import "BillsDetailViewController.h"
#import "JSON.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"

@interface BillsFavoritesViewController (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)save:(id)sender;
- (NSString *)watchIDForBill:(NSDictionary *)aBill;
@end

@implementation BillsFavoritesViewController


#pragma mark -
#pragma mark View lifecycle

/*
- (void)didReceiveMemoryWarning {
	[_cachedBills release];
	_cachedBills = nil;	
}*/

- (void)viewDidLoad {
	[super viewDidLoad];
		
	if (!_requestDictionary)
		_requestDictionary = [[[NSMutableDictionary alloc] init] retain];
	
	if (!_requestSenders)
		_requestSenders = [[[NSMutableDictionary alloc] init] retain];	
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = [[self class] description];
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];
	
	[[self navigationItem] setRightBarButtonItem:[self editButtonItem] animated:YES];
	
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	
	
	thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:thePath]) {
		NSArray *tempArray = [[NSArray alloc] init];
		[tempArray writeToFile:thePath atomically:YES];
		[tempArray release];
	}
	
	
	/*
	if ([_watchList count] == 0) {
		//[_watchList removeAllObjects];
		for (NSInteger count = 0; count < 6; count++) {
			NSDictionary *itemDict = [[NSDictionary alloc] initWithObjectsAndKeys:
									  [NSNumber numberWithInt:count], @"displayOrder",
									  [NSString stringWithFormat:@"Item %d", count], @"name",
									  [NSString stringWithFormat:@"Description for %d", count], @"description",
									  nil];
			[_watchList addObject:itemDict];
			[itemDict release];
		}
	}*/
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_watchList) {
		[_watchList release];
		_watchList = nil;
	}
	NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
	_watchList = [[[NSMutableArray alloc] initWithContentsOfFile:thePath] retain];
	if (!_watchList)
		_watchList = [[[NSMutableArray alloc] init] retain];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	[_watchList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];	
	
	if (![_watchList count]) {
		UIAlertView *noWatchedBills = [[[ UIAlertView alloc ] 
										 initWithTitle:@"No Watched Bills, Yet" 
										 message:@"To add a bill to this watch list, first search for one, open it, and then tab the star button in it's header." 
										 delegate:nil // we're static, so don't do "self"
										 cancelButtonTitle: @"Cancel" 
										 otherButtonTitles:nil, nil] autorelease];
		[ noWatchedBills show ];		
		
	}
	[self.tableView reloadData];
	
	[self refreshAllBills:nil];

}

/*- (void)viewWillDisappear:(BOOL)animated {
//	[self save:nil];
	[super viewWillDisappear:animated];
}*/

- (NSString *)watchIDForBill:(NSDictionary *)aBill {
	if (aBill && [aBill objectForKey:@"session"] && [aBill objectForKey:@"bill_id"])
		return [NSString stringWithFormat:@"%@:%@", [aBill objectForKey:@"session"],[aBill objectForKey:@"bill_id"]]; 
	else
		return @"";
}

- (IBAction)refreshBill:(NSDictionary *)watchedItem sender:(id)sender {
	NSString *queryString = [NSString stringWithFormat:@"http://openstates.sunlightlabs.com/api/v1/bills/tx/%@/%@/?apikey=350284d0c6af453b9b56f6c1c7fea1f9", 
							 [watchedItem objectForKey:@"session"], [[watchedItem objectForKey:@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[self JSONRequestWithURLString:queryString sender:sender];
}

- (IBAction)refreshAllBills:(id)sender {
	if (_cachedBills) {
		[_cachedBills release];
		_cachedBills = nil;
	}
	
	_cachedBills = [[[NSMutableDictionary alloc] init] retain];
	
	for (NSDictionary *item in _watchList) {
		[self refreshBill:item sender:item];
	}	
}

- (IBAction)save:(id)sender {
	if (_watchList) {
		NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillFavoritesStorageFile];
		[_watchList writeToFile:thePath atomically:YES];		
	}
}

- (void)viewDidUnload {
	[_requestDictionary release];
	_requestDictionary = nil;
	[_requestSenders release];
	_requestSenders = nil;
	[super viewDidUnload];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	cell.textLabel.text = [[_watchList objectAtIndex:indexPath.row] objectForKey:@"name"];
	cell.detailTextLabel.text = [[_watchList objectAtIndex:indexPath.row] objectForKey:@"description"];	
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
	if (_watchList && [_watchList count])
		return [_watchList count];
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = @"CellOff";
	if (_watchList && [_watchList count] > indexPath.row) {
		NSString *watchID = [[_watchList objectAtIndex:indexPath.row] objectForKey:@"watchID"];
		if (_cachedBills && [[_cachedBills allKeys] containsObject:watchID])
			CellIdentifier = @"CellOn";
	}
	
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
	
	if (_watchList && [_watchList count])
		[self configureCell:cell atIndexPath:indexPath];		
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSDictionary *toRemove = [_watchList objectAtIndex:indexPath.row];
		if (toRemove && _cachedBills) {
			NSString *watchID = [toRemove objectForKey:@"watchID"];
			if (watchID && [[_cachedBills allKeys] containsObject:watchID])
				[_cachedBills removeObjectForKey:watchID];
		}
		[_watchList removeObjectAtIndex:indexPath.row];
		[self save:nil];		
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
      toIndexPath:(NSIndexPath *)destinationIndexPath;
{  	
	if (!_watchList)
		return;
	
	NSDictionary *item = [[_watchList objectAtIndex:sourceIndexPath.row] retain];	
	[_watchList removeObject:item];
	[_watchList insertObject:item atIndex:[destinationIndexPath row]];	
	[item release];
	
	int i = 0;
	for (NSMutableDictionary *anItem in _watchList)
		[anItem setValue:[NSNumber numberWithInt:i++] forKey:@"displayOrder"];
	
	[self save:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (!_watchList)
		return;
	
	NSDictionary *item = [_watchList objectAtIndex:indexPath.row];
	if (item && [item objectForKey:@"watchID"]) {
		NSDictionary *bill = [_cachedBills objectForKey:[item objectForKey:@"watchID"]];
		if (bill) {
			BillsDetailViewController *detailView = [[[BillsDetailViewController alloc] 
													  initWithNibName:@"BillsDetailViewController" bundle:nil] autorelease];
						
			[detailView setDataObject:bill];
			if (![UtilityMethods isIPadDevice])
				[self.navigationController pushViewController:detailView animated:YES];
			else
				[[[TexLegeAppDelegate appDelegate] detailNavigationController] pushViewController:detailView animated:NO];
			
		}			
	}
}

- (void)dealloc {	

	if (_watchList) {
		[_watchList release];
		_watchList = nil;
	}
	if (_cachedBills) {
		[_cachedBills release];
		_cachedBills = nil;
	}
	
	[_requestDictionary release];
	_requestDictionary = nil;
	[_requestSenders release];
	_requestSenders = nil;
	
	
	[super dealloc];
}

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
	
	/*	if (connection) {
	 [connection release];
	 connection = nil;
	 }
	 */
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
	
	/*    [connection release];
	 connection = nil;
	 */
}

@end


