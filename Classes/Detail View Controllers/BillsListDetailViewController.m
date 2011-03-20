//
//  BillsListDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsListDetailViewController.h"
#import "TexLegeAppDelegate.h"
#import "BillsDetailViewController.h"
#import "JSON.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "BillSearchDataSource.h"
#import "LegislativeAPIUtils.h"

@interface BillsListDetailViewController (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BillsListDetailViewController
@synthesize dataSource;

#pragma mark -
#pragma mark View lifecycle

/*
 - (void)didReceiveMemoryWarning {
 [_cachedBills release];
 _cachedBills = nil;	
 }*/

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		dataSource = [[[BillSearchDataSource alloc] initWithTableViewController:self] retain];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (!_requestDictionary)
		_requestDictionary = [[[NSMutableDictionary alloc] init] retain];
	
	if (!_requestSenders)
		_requestSenders = [[[NSMutableDictionary alloc] init] retain];	
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self.dataSource;
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

/*- (void)viewWillDisappear:(BOOL)animated {
 //	[self save:nil];
 [super viewWillDisappear:animated];
 }*/


- (IBAction)refreshBill:(NSDictionary *)watchedItem sender:(id)sender {
	NSString *queryString = [NSString stringWithFormat:@"%@/bills/tx/%@/%@/?%@", osApiBaseURL,
							 [watchedItem objectForKey:@"session"], 
							 [[watchedItem objectForKey:@"bill_id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							 osApiKey];
	
	[self JSONRequestWithURLString:queryString sender:sender];
}

- (void)viewDidUnload {
	[_requestDictionary release];
	_requestDictionary = nil;
	[_requestSenders release];
	_requestSenders = nil;
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *bill = [dataSource dataObjectForIndexPath:indexPath];
	if (bill && [bill objectForKey:@"bill_id"]) {
		if (bill) {
						
			BOOL changingViews = NO;
			
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
			[self refreshBill:bill sender:detailView];
			
			if (![UtilityMethods isIPadDevice])
				[self.navigationController pushViewController:detailView animated:YES];
			else if (changingViews)
				[[[TexLegeAppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:detailView] animated:NO];
		}			
	}
}

- (void)dealloc {	
		
	[_requestDictionary release];
	_requestDictionary = nil;
	[_requestSenders release];
	_requestSenders = nil;
	
	[dataSource release];
	
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
	
	if (sender && object) {		
		[sender setDataObject:object];
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



