//
//  LegislatorContributionsViewController.m
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LegislatorContributionsViewController.h"
#import "TexLegeCoreDataUtils.h"
#import "LegislatorObj.h"
#import "UtilityMethods.h"
#import "JSON.h"

static const NSString *apiKey = @"&apikey=350284d0c6af453b9b56f6c1c7fea1f9";

@interface LegislatorContributionsViewController (Private)
- (void)initiateQueryWithLegislator:(LegislatorObj *)aLegislator;
- (void)createSectionWithData:(NSData *)jsonData;
@end

@implementation LegislatorContributionsViewController
@synthesize topContributors, legislator, urlConnection, receivedData;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidUnload {
	[self.urlConnection cancel];
	self.urlConnection = nil;
    self.topContributors = nil;
	self.receivedData = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // Relinquish ownership any cached data, images, etc that aren't in use.
	self.legislator = nil;
	[self.urlConnection cancel];
	self.urlConnection = nil;
	self.receivedData = nil;
}


- (void)dealloc {
	[self.urlConnection cancel];
	self.urlConnection = nil;
	self.legislator = nil;
	self.topContributors = nil;
	self.receivedData = nil;
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Data Objects
- (void)setLegislator:(LegislatorObj *)newObj {
	[self view];
	
	if (legislator) [legislator release], legislator = nil;
	if (newObj) {		
		legislator = [newObj retain];
		self.navigationItem.title = @"Top 20 Contributors";
		
		[self initiateQueryWithLegislator:legislator];
	}
	
}

- (void)establishConnectionWithURL:(NSURL *)url {
	// Create the request.
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:15.0];
	// create the connection with the request
	// and start loading the data
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
	NSArray *tempArray = [jsonString JSONValue];	
	[jsonString release];
	[connection release];
	self.receivedData = nil;

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	[numberFormatter setMaximumFractionDigits:0];

	self.topContributors = [NSMutableArray arrayWithCapacity:[tempArray count]];
	for (NSDictionary *dict in tempArray) {
		NSString *name = [[dict objectForKey:@"name"] capitalizedString];
		
		double tempDouble = [[dict objectForKey:@"total_amount"] doubleValue];
		NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
		NSString *amountString = [numberFormatter stringFromNumber:amount];
		NSString *contribId = [dict objectForKey:@"id"];

		NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
								  name, @"name",
								  amount, @"amount",
								  amountString, @"amountString",
								  contribId, @"contribId",
								  nil];
		[self.topContributors addObject:tempDict];
		[tempDict release];
	}
	[numberFormatter release];
	
	[self.tableView reloadData];
	[self.view setNeedsDisplay];
}

- (void)initiateQueryWithLegislator:(LegislatorObj *)aLegislator {
	// http://transparencydata.com/api/1.0/aggregates/pol/7c299471e4414887acc94f98785a90b0/contributors.json?apikey=350284d0c6af453b9b56f6c1c7fea1f9&limit=20
	
	static const NSString *urlRoot = @"http://transparencydata.com/api/1.0/aggregates/pol/";
	static const NSString *urlMethod = @"/contributors.json?limit=20";
	
	//NSString *memberTransDataID = @"7c299471e4414887acc94f98785a90b0";	// this will change with each legislator
	NSString *memberID = self.legislator.transDataContributorID;
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", urlRoot, memberID, urlMethod, apiKey];
	NSURL *url = [NSURL URLWithString:urlString];
		
	if ([UtilityMethods canReachHostWithURL:url alert:YES]) {
		[self establishConnectionWithURL:url];
	}
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.topContributors count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		/*
		 UITableViewCellStyleDefault,	// Simple cell with text label and optional image view (behavior of UITableViewCell in iPhoneOS 2.x)
		 UITableViewCellStyleValue1,		// Left aligned label on left and right aligned label on right with blue text (Used in Settings)
		 UITableViewCellStyleValue2,		// Right aligned label on left with blue text and left aligned label on right (Used in Phone/Contacts)
		 UITableViewCellStyleSubtitle	// Left aligned label on top and left aligned label on bottom with gray text (Used in iPod).
*/
		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	NSDictionary *dataObject = [self.topContributors objectAtIndex:indexPath.row];

    cell.detailTextLabel.text = [dataObject objectForKey:@"amountString"];
    cell.textLabel.text = [dataObject objectForKey:@"name"];
	
    // Configure the cell...
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}



@end

