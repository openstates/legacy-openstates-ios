//
//  BillsCategoriesViewController.m
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsCategoriesViewController.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "TexLegeReachability.h"
#import "BillsListDetailViewController.h"
#import "BillSearchDataSource.h"
#import "TexLegeBadgeGroupCell.h"
#import "BillMetadataLoader.h"
#import "OpenLegislativeAPIs.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "LoadingCell.h"

@interface BillsCategoriesViewController (Private)
- (void)configureCell:(TexLegeBadgeGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)createChamberControl;
- (IBAction)filterChamber:(id)sender;
- (IBAction)loadCategoriesForChamber:(NSInteger)newChamber;
@end

@implementation BillsCategoriesViewController
@synthesize chamberControl, chamberCategories;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if (self=[super initWithStyle:style]) {
		loadingStatus = LOADING_IDLE;
		categories_ = [[[NSMutableDictionary alloc] init] retain];
		updated = nil;
		isFresh = NO;
	}
	return self;
}

- (void)dealloc {	
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	self.chamberControl = nil;
	if (updated)
		[updated release], updated = nil;
	if (categories_)
		[categories_ release], categories_ = nil;
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>1)
		[nav popToRootViewControllerAnimated:YES];
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = NSStringFromClass([self class]);
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];
	
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	[self createChamberControl];
	
	self.chamberControl.tintColor = [TexLegeTheme accent];
	self.navigationItem.titleView = self.chamberControl;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 28)];
	label.backgroundColor = [TexLegeTheme accent];
	label.font = [TexLegeTheme boldFifteen];
	//label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [TexLegeTheme backgroundLight];
	label.lineBreakMode = UILineBreakModeTailTruncation;
	//label.numberOfLines =
	label.text = @"Large subjects download slowly."; 
	self.tableView.tableHeaderView = label;
	[label release];
	
	[self chamberCategories];	// load them from the network, if necessary
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSNumber *segIndex = [segPrefs objectForKey:NSStringFromClass([self class])];
		if (segIndex)
			self.chamberControl.selectedSegmentIndex = [segIndex integerValue];
	}
}

- (IBAction)filterChamber:(id)sender {
	NSDictionary *segPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSegmentControlPrefKey];
	if (segPrefs) {
		NSString *segIndex = [NSString stringWithFormat:@"%d",self.chamberControl.selectedSegmentIndex];
		NSMutableDictionary *newDict = [segPrefs mutableCopy];
		[newDict setObject:segIndex forKey:NSStringFromClass([self class])];
		[[NSUserDefaults standardUserDefaults] setObject:newDict forKey:kSegmentControlPrefKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[newDict release];
	}
	
	[self.tableView reloadData];
}

- (NSString *)chamber {
	NSInteger theChamber = BOTH_CHAMBERS;
	if (chamberControl)
		theChamber = chamberControl.selectedSegmentIndex;
	return [NSString stringWithFormat:@"%d", theChamber];
}

- (void)viewDidUnload {
	self.chamberControl = nil;
	[super viewDidUnload];
}

- (void)configureCell:(TexLegeBadgeGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if (!categories_ || IsEmpty([categories_ objectForKey:self.chamber]))
		return;

	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	NSDictionary *category = [[categories_ objectForKey:self.chamber] objectAtIndex:indexPath.row];
	
	BOOL clickable = [[category objectForKey:kBillCategoriesCountKey] integerValue] > 0;
	NSDictionary *cellDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [category objectForKey:kBillCategoriesCountKey], @"entryValue",
							  [NSNumber numberWithBool:clickable], @"isClickable",
							  [category objectForKey:kBillCategoriesTitleKey], @"title",
							  nil];
	TableCellDataObject *cellInfo = [[TableCellDataObject alloc] initWithDictionary:cellDict];
	cell.cellInfo = cellInfo;
	[cellInfo release];
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
	if (categories_ && !IsEmpty([categories_ objectForKey:self.chamber]))
		return [[categories_ objectForKey:self.chamber] count];
	else if (loadingStatus > LOADING_IDLE)
		return 1;
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (loadingStatus > LOADING_IDLE) {
		if (indexPath.row == 0) {
			return [LoadingCell loadingCellWithStatus:loadingStatus tableView:tableView];
		}
		else {	// to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}
	
	NSString *CellIdentifier = [TexLegeBadgeGroupCell cellIdentifier];
		
	TexLegeBadgeGroupCell *cell = (TexLegeBadgeGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[TexLegeBadgeGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:CellIdentifier] autorelease];		
    }
	
	[self configureCell:cell atIndexPath:indexPath];		
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (!categories_ ||  ([[categories_ objectForKey:self.chamber] count] <= indexPath.row))
		return;
	
	NSDictionary *item = [[categories_ objectForKey:self.chamber] objectAtIndex:indexPath.row];
	if (item && [item objectForKey:kBillCategoriesTitleKey]) {
		NSString *cat = [item objectForKey:kBillCategoriesTitleKey];
		NSInteger count = [[item objectForKey:kBillCategoriesCountKey] integerValue];
		if (cat && count) {
			BillsListDetailViewController *catResultsView = [[[BillsListDetailViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
			BillSearchDataSource *dataSource = [catResultsView valueForKey:@"dataSource"];
			catResultsView.title = cat;
			[dataSource startSearchForSubject:cat chamber:[self.chamber integerValue]];
			
			[self.navigationController pushViewController:catResultsView animated:YES];
		}			
	}	
}

#pragma mark Properties

//http://openstates.sunlightlabs.com/api/v1/subject_counts/tx/82/upper/?apikey=350284d0c6af453b9b56f6c1c7fea1f9
//We now get subject frequency counts, filtered by state, session and originating chamber.

- (IBAction)loadCategoriesForChamber:(NSInteger)newChamber {
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:osApiBaseURL] alert:NO]) {
		loadingStatus = LOADING_ACTIVE;
		OpenLegislativeAPIs *api = [OpenLegislativeAPIs sharedOpenLegislativeAPIs];
		
		NSDictionary *queryParams = [NSDictionary dictionaryWithObject:osApiKeyValue forKey:@"apikey"];
		NSMutableString *resourcePath = [NSMutableString stringWithFormat:@"/subject_counts/tx/%@/", api.currentSession];
		if (newChamber > BOTH_CHAMBERS)
			[resourcePath appendFormat:@"%@/", stringForChamber(newChamber, TLReturnOpenStates)];
			
		[[api osApiClient] get:resourcePath queryParams:queryParams delegate:self];
	}
	else {
		loadingStatus = LOADING_NO_NET;
	}
}

- (NSMutableDictionary*)chamberCategories {
	if (!categories_ || 
		(!isFresh && ![categories_ objectForKey:self.chamber]) || 
		!updated || 
		([[NSDate date] timeIntervalSinceDate:updated] > 3600*24)) {	// if we're over a day old, let's refresh
		isFresh = NO;
		debug_NSLog(@"BillCategories is stale, need to refresh");
		
		[self loadCategoriesForChamber:BOTH_CHAMBERS];	// let's get everything
	}
	return categories_;
}


#pragma mark -
#pragma mark Chamber Control

- (void)createChamberControl {
	UISegmentedControl *ctl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"House", @"Senate", nil]];
	ctl.frame = CGRectMake(0.0, 0.0, 163.0, 30.0);
	ctl.autoresizesSubviews = YES;
	ctl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	ctl.clipsToBounds = NO;
	ctl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	ctl.contentMode = UIViewContentModeScaleToFill;
	ctl.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	ctl.enabled = YES;
	ctl.opaque = NO;
	ctl.segmentedControlStyle = UISegmentedControlStyleBar;
	ctl.selectedSegmentIndex = 0;
	ctl.userInteractionEnabled = YES;
	self.chamberControl = ctl;
	[ctl release];
	[self.chamberControl addTarget:self action:@selector(filterChamber:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading categories from %@: %@", [request description], [error localizedDescription]);
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kBillCategoriesNotifyError object:nil];
	loadingStatus = LOADING_IDLE;

	isFresh = NO;
	
	if (categories_)
		[categories_ release];
	
	// We had trouble loading the events online, so pull up the cache from the one in the documents folder, if possible
	NSString *thePath = [[UtilityMethods applicationCachesDirectory] stringByAppendingPathComponent:kBillCategoriesCacheFile];
	//NSString *thePath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kCalendarEventsCacheFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:thePath]) {
		debug_NSLog(@"BillCategories: using cached categories in the documents folder.");
		//categories_ = [[NSMutableDictionary dictionaryWithContentsOfFile:thePath] retain];
		NSData *json = [NSData dataWithContentsOfFile:thePath];
		if (json)
			categories_ = [[json mutableObjectFromJSONData] retain];
	}
	if (!categories_) {
		categories_ = [[NSMutableDictionary dictionary] retain];
		loadingStatus = LOADING_NO_NET;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kBillCategoriesNotifyLoaded object:nil];
	
	[self.tableView reloadData];

}


- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		
		NSMutableDictionary *newCats = [response.body mutableObjectFromJSONData];
		if (!newCats)
			return;
		
		NSMutableArray *newArray = [[NSMutableArray alloc] init];
		for (NSString *name in [newCats allKeys]) {
			NSNumber *total = [newCats objectForKey:name];
			NSMutableDictionary *newEntry = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 name, kBillCategoriesTitleKey,
											 total, kBillCategoriesCountKey,
											 nil];
			[newArray addObject:newEntry];
			[newEntry release];
		}
		NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:kBillCategoriesTitleKey ascending:YES];
		[newArray sortUsingDescriptors:[NSArray arrayWithObject:desc]];
		
		NSInteger inChamber = BOTH_CHAMBERS;
		if ([[request resourcePath] hasSubstring:@"/upper" caseInsensitive:NO])
			inChamber = SENATE;
		else if ([[request resourcePath] hasSubstring:@"/lower" caseInsensitive:NO])
			inChamber = HOUSE;

		[categories_ setObject:newArray forKey:[NSString stringWithFormat:@"%d", inChamber]];
		[newArray release];
		
		if (inChamber < SENATE)
			[self loadCategoriesForChamber:inChamber+1];	// let's load the next chamber too
		
		if ([[categories_ allKeys] count] == 3) { // once we have all three arrays ready to go, let's save it
			NSString *thePath = [[UtilityMethods applicationCachesDirectory] stringByAppendingPathComponent:kBillCategoriesCacheFile];
			NSError *error = nil;
			NSData *json = [categories_ JSONDataWithOptions:JKSerializeOptionEscapeUnicode error:&error];
			if (![json writeToFile:thePath atomically:YES]) {
				NSLog(@"BillCategories: Error writing categories cache to file: %@ = %@", [error localizedDescription], thePath);
			}
		}
		
		isFresh = YES;
		if (updated)
			[updated release];
		updated = [[NSDate date] retain];
		
		loadingStatus = LOADING_IDLE;

		[[NSNotificationCenter defaultCenter] postNotificationName:kBillCategoriesNotifyLoaded object:nil];
		
		[self.tableView reloadData];
	}
}
@end


