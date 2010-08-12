//
//  LinksMenuDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LinksMenuDataSource.h"
#import "TexLegeAppDelegate.h"
#import "LinkObj.h"
#import "UtilityMethods.h"

@interface LinksMenuDataSource (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)saveAction:(id)sender;
@end

@implementation LinksMenuDataSource

enum Sections {
    kHeaderSection = 0,
    kBodySection,
    NUM_SECTIONS
};
enum HeaderSectionRows {
    kHeaderSectionThisAppRow = 0,
	kHeaderSectionContactRow,
    NUM_HEADER_SECTION_ROWS,		
};

@synthesize fetchedResultsController, managedObjectContext;


#if NEEDS_TO_INITIALIZE_DATABASE
@synthesize linksData;
#endif

#pragma mark -
#pragma mark TableDataSourceProtocol methods
// return the data used by the navigation controller and tab bar item

- (NSString *)name
{ return @"Resources"; }

- (NSString *)navigationBarName
{ return @"Resources and Info"; }

- (UIImage *)tabBarImage {
	return [UIImage imageNamed:@"113-navigation.png"];
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

// setup the data collection
- init {
	if (self = [super init]) {
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init]) {
		if (newContext) self.managedObjectContext = newContext;
	
		//[self populateLinksArrays];
		NSError *error = nil;
		if (![[self fetchedResultsController] performFetch:&error])
		{
			debug_NSLog(@"LinksMenuDataSource-init: Unresolved error %@, %@", error, [error userInfo]);
		}		
	}
	return self;
}

- (void)dealloc {	
#if NEEDS_TO_INITIALIZE_DATABASE
	[linksData release];
#endif
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;

    [super dealloc];
}

#if NEEDS_TO_INITIALIZE_DATABASE
#warning initializeDatabase IS TURNED ON!!!
#warning DON'T FORGET TO LINK IN THE APPROPRIATE PLIST FILES

- (void) setupDataArray {
//#error **** MAKE SURE YOU RE-ENABLE LINK FOR "Links.plist"
	NSString *DataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Links.plist"];		
	NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	NSArray *tempArray = [[NSArray alloc] initWithArray:[tempDict objectForKey:@"Links"]];
	self.linksData = tempArray;
	[tempArray release];
	[tempDict release];		
}

- (void)initializeDatabase {
	NSInteger count = [[self.fetchedResultsController sections] count];
	if (count == 0) { // try initializing it...
		
		// if numberOfSections is dynamic, we should move this up...
		if (self.linksData == nil) {
			[self setupDataArray];
		}
		
		// Create a new instance of the entity managed by the fetched results controller.
		NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
		
		for (NSDictionary *dictionary in self.linksData) {
			NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:
												 [entity name] inManagedObjectContext:self.managedObjectContext];
			
			[newManagedObject setValuesForKeysWithDictionary:dictionary];
/*			[newManagedObject setValue:[dictionary objectForKey:@"label"] forKey:@"label"];
			[newManagedObject setValue:[dictionary objectForKey:@"url"] forKey:@"url"];
			[newManagedObject setValue:[dictionary objectForKey:@"order"] forKey:@"order"];
			[newManagedObject setValue:[dictionary objectForKey:@"section"] forKey:@"section"];
			[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
*/			
		}
		[self saveAction:nil];			
	}
}
#endif

#pragma mark -
#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == kHeaderSection)
		return @"This Application";
	else
		return @"Web Resources";		
}

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	LinkObj * link = [fetchedResultsController objectAtIndexPath:indexPath];	
	return link;	
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	LinkObj *link = [self dataObjectForIndexPath:indexPath];
	cell.textLabel.text = link.label;
	
	if (indexPath.section == kBodySection)
		cell.detailTextLabel.text = link.url;
	
	//[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger section = indexPath.section;
	
	NSString *CellIdentifier = @"Cell";

	if (section == kHeaderSection)
			CellIdentifier = @"LinksHeader";
	else
		CellIdentifier = @"LinksBodyLink";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		UITableViewCellStyle style = UITableViewCellStyleSubtitle;
		UITableViewCellAccessoryType disclosure = UITableViewCellAccessoryDisclosureIndicator;

		if (section == kHeaderSection) {
			style = UITableViewCellStyleDefault;
			disclosure = UITableViewCellAccessoryDetailDisclosureButton;
		}

		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"Cell"] autorelease];
		cell.accessoryType = disclosure;


	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


#pragma mark -
#pragma mark Core Data
- (IBAction)saveAction:(id)sender{
	
	@try {
		NSError *error = nil;
		if (self.managedObjectContext != nil) {
			if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
				debug_NSLog(@"LinksMenuDataSource:save - unresolved error %@, %@", error, [error userInfo]);
			} 
		}
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in LinksMenuDataSource:save, name=%@ reason=%@", e.name, e.reason);
	}
}

	
#pragma mark -
#pragma mark Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{  
	if (fetchedResultsController != nil) return fetchedResultsController;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LinkObj" inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortSection = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortSection, sortOrder, nil];  
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		debug_NSLog(@"There's no links objects ???");
	}
	for (LinkObj *object in fetchedObjects) {
		if ([object.section integerValue] == kHeaderSection) {
			debug_NSLog(@"%@", object.url);
			if ([object.url isEqualToString:@"voteInfoView"]) {	// we've changed out this old thingy
				object.url = @"contactMail";
				object.label = @"Contact TexLege Support";
			}
		}
	}	
	[self saveAction:nil];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:managedObjectContext
																								  sectionNameKeyPath:@"section" cacheName:@"LinksCache"];
	aFetchedResultsController.delegate = self;
	[self setFetchedResultsController:aFetchedResultsController];
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortSection release];
	[sortOrder release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

@end
