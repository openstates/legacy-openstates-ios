//
//  BillsDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "BillsDataSource.h"
#import "TexLegeAppDelegate.h"


@implementation BillsDataSource

@synthesize fetchedResultsController, managedObjectContext;

#pragma mark -
#pragma mark TableDataSourceProtocol methods
// return the data used by the navigation controller and tab bar item

- (NSString *)navigationBarName 
{ return @"Bills and Legislation"; }

- (NSString *)name
{ return @"Bills"; }

- (UIImage *)tabBarImage
{ return [UIImage imageNamed:@"06-magnifying-glass.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)usesToolbar
{ return NO; }

- (BOOL)usesSearchbar
{ return YES; }

- (BOOL)canEdit
{ return NO; }


// atomic state is displayed in a grouped style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
} 

// setup the data collection
- init {
	if (self = [super init]) {		
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init])
		if (newContext) self.managedObjectContext = newContext;
	return self;
}

- (void)dealloc {	
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
    [super dealloc];
}

#if 0
- (void) setupDataArray {
	NSString *DataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Links.plist"];		
	NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	NSArray *tempArray = [[NSArray alloc] initWithArray:[tempDict objectForKey:@"Links"]];
	self.linksData = tempArray;
	[tempArray release];
	[tempDict release];		
}
#endif

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0
	NSString *CellIdentifier = [NSString stringWithFormat:@"Links Section %d", indexPath.section];
	NSInteger properRow = indexPath.section > 0 ? indexPath.row + 2 : indexPath.row;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (indexPath.section == 0) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}	
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
    
    // Set up the cell...
	NSDictionary *dictionary = [self.linksData objectAtIndex:properRow];
	if (indexPath.section == 0) {
		cell.textLabel.text = [dictionary objectForKey:@"label"];
		//cell.imageView.image = [UIImage imageNamed:@"Icon.png"];
	}
	else {
		cell.detailTextLabel.text = [dictionary objectForKey:@"url"];
		cell.textLabel.text = [dictionary objectForKey:@"label"];
	}
	
    return cell;
#else
	return nil;
#endif
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
	// this table has multiple sections. One for each physical state
	// [solid, liquid, gas, artificial]
	// return the number of items in the states array
#if 0
	return 2;
#else
	return 0;
#endif
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
#if 0
	// this is one of the first methods called when the view is loading, so initialize here.
	// if numberOfSections is dynamic, we should move this up...
	if (self.linksData == nil) {
		[self setupDataArray];
	}

	if (section == 0) 
		return kNumInfoViewItems; // Two About View Items
	else
		return [self.linksData count] - kNumInfoViewItems;
#else
	return 0;
#endif
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
#if 0
	if (section == 0) 
		return @"This Application"; // Two About View Items
	else
		return @"Web Resources";
#else
	return nil;
#endif
}

@end
