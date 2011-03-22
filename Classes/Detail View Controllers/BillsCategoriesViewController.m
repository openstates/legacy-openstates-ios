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
#import "TexLegeStandardGroupCell.h"
#import "BillMetadataLoader.h"

@interface BillsCategoriesViewController (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
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

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshCategories:) name:kBillMetadataNotifyLoaded object:nil];

	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = [[self class] description];
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];
	
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	
	[self refreshCategories:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}


- (IBAction)refreshCategories:(NSNotificationCenter *)notification {
	if (_CategoriesList)
		[_CategoriesList release];
	_CategoriesList = [[[[[BillMetadataLoader sharedBillMetadataLoader] metadata] objectForKey:kBillMetadataSubjectsKey] mutableCopy] retain];	
	if (_CategoriesList && [_CategoriesList count]) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kBillMetadataTitleKey ascending:YES];
		[_CategoriesList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];	
		
	}		
	[self.tableView reloadData];
}

- (void)viewDidUnload {
	[_CategoriesList release];
	_CategoriesList = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	NSDictionary *category = [_CategoriesList objectAtIndex:indexPath.row];
	cell.detailTextLabel.text = [category objectForKey:kBillMetadataTitleKey];
	cell.textLabel.text = [NSString stringWithFormat:@"Approx. %@ Bills", [category objectForKey:kBillMetadataSubjectsCountKey]];
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
	NSString *CellIdentifier = [TexLegeStandardGroupCell cellIdentifier];
		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:CellIdentifier] autorelease];		
    }
	
	if (_CategoriesList && [_CategoriesList count])
		[self configureCell:cell atIndexPath:indexPath];		
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (!_CategoriesList || ![_CategoriesList count]>indexPath.row)
		return;
	
	NSDictionary *item = [_CategoriesList objectAtIndex:indexPath.row];
	if (item && [item objectForKey:kBillMetadataTitleKey]) {
		NSString *cat = [item objectForKey:kBillMetadataTitleKey];
		if (cat) {
			BillsListDetailViewController *catResultsView = [[[BillsListDetailViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
			BillSearchDataSource *dataSource = [catResultsView valueForKey:@"dataSource"];
			catResultsView.title = cat;
			[dataSource startSearchForSubject:cat chamber:BOTH_CHAMBERS];
			
			[self.navigationController pushViewController:catResultsView animated:YES];
		}			
	}
}

- (void)dealloc {	
	
	if (_CategoriesList) {
		[_CategoriesList release];
		_CategoriesList = nil;
	}
	
	[super dealloc];
}

@end


