//
//  LinksMenuDataSource.m
//  Created by Gregory S. Combs on 5/24/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LinksDataSource.h"
#import "StatesLegeAppDelegate.h"
#import "LinkObj.h"
#import "UtilityMethods.h"
#import "TexLegeStandardGroupCell.h"
#import "TexLegeTheme.h"

@implementation LinksDataSource

enum Sections {
    kHeaderSection = 0,
    kBodySection,
    NUM_SECTIONS
};

@synthesize fetchedResultsController;

#pragma mark -
#pragma mark TableDataSourceProtocol methods

- (NSString *)name 
{ return NSLocalizedStringFromTable(@"Resources", @"StandardUI", @"The short title for buttons and tabs related to web links (for more information, see ...)"); }

- (NSString *)navigationBarName 
{ return NSLocalizedStringFromTable(@"Resources and Info", @"StandardUI", @"The long title for buttons and tabs related to web links (for more information, see ...)"); }

- (UIImage *)tabBarImage {
	return [UIImage imageNamed:@"113-navigation-inv.png"];
}

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return YES; }

- (BOOL)canEdit
{ return YES; }

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
} 

- (Class)dataClass {
	return [LinkObj class];
}

- (id)init {
	if ((self = [super init])) {
	
		//NSError *error = nil;
		/*if (![self.fetchedResultsController performFetch:&error])
		{
			debug_NSLog(@"LinksMenuDataSource-init: Unresolved error %@, %@", error, [error userInfo]);
		}*/		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];	
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resetCoreData:) name:@"RESTKIT_LOADED_LINKOBJ" object:nil];	
	}
	return self;
}

- (void)resetCoreData:(NSNotification *)notification {
	[NSFetchedResultsController deleteCacheWithName:[self.fetchedResultsController cacheName]];
	self.fetchedResultsController = nil;
	NSError *error = nil;
	[self.fetchedResultsController performFetch:&error];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.fetchedResultsController = nil;
    [super dealloc];
}

-(void)dataSourceReceivedMemoryWarning:(id)sender {
	// let's give this a swinging shot....	
	for (NSManagedObject *object in self.fetchedResultsController.fetchedObjects) {
		[[LinkObj managedObjectContext] refreshObject:object mergeChanges:NO];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == kHeaderSection)
		return NSLocalizedStringFromTable(@"This Application", @"DataTableUI", @"Table section listing resources for this application");
	else
		return NSLocalizedStringFromTable(@"Web Resources", @"DataTableUI", @"Table section listing resources on the web");		
}

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {		
	return [self.fetchedResultsController objectAtIndexPath:indexPath];;	
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	NSIndexPath *tempIndex = nil;
	@try {
		tempIndex = [self.fetchedResultsController indexPathForObject:dataObject];
	}
	@catch (NSException * e) {
	}
	
	return tempIndex;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger section = indexPath.section;
	
	NSString *CellIdentifier = @"Cell";

	if (section == kHeaderSection)
		CellIdentifier = @"LinksHeader";
	else
		CellIdentifier = @"LinksBodyLink";
	
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{		
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
		if (section == kHeaderSection) {
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}		
		
		cell.textLabel.font = [TexLegeTheme boldFifteen];
		cell.textLabel.textColor = [TexLegeTheme textDark];
		cell.detailTextLabel.textColor = [TexLegeTheme indexText];
	}
	
	LinkObj *link = [self dataObjectForIndexPath:indexPath];
	if (link) {
		cell.textLabel.text = link.label;
		
		if (indexPath.section == kBodySection)
			cell.detailTextLabel.text = link.url;
	}
	return cell;
}
	
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TABLEUPDATE_START" object:self];
	//    [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TABLEUPDATE_END" object:self];
	//    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{  
	if (fetchedResultsController != nil) return fetchedResultsController;
	
	NSFetchRequest *fetchRequest = [LinkObj fetchRequest];
	
	NSSortDescriptor *sortSection = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortSection, sortOrder, nil];  
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																   managedObjectContext:[LinkObj managedObjectContext]
																	 sectionNameKeyPath:@"section" cacheName:@"Links"];
	fetchedResultsController.delegate = self;
	
	[sortSection release];
	[sortOrder release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

@end
