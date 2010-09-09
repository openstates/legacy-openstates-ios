//
//  LinksMenuDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LinksDataSource.h"
#import "TexLegeAppDelegate.h"
#import "LinkObj.h"
#import "UtilityMethods.h"
#import "DisclosureQuartzView.h"

@interface LinksDataSource (Private)
- (IBAction)saveAction:(id)sender;


#if NEEDS_TO_INITIALIZE_DATABASE == 1 || JUST_INITIALIZE_LINKS == 1
- (void) setupDataArray;
- (void) initializeDatabase;
#endif

@end

@implementation LinksDataSource

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


#if NEEDS_TO_INITIALIZE_DATABASE == 1 || JUST_INITIALIZE_LINKS == 1
@synthesize linksData;
#endif

#pragma mark -
#pragma mark TableDataSourceProtocol methods

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

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext) self.managedObjectContext = newContext;
	
#if NEEDS_TO_INITIALIZE_DATABASE == 1 || JUST_INITIALIZE_LINKS == 1
#error now that we have lots of view controllers in the tabs, this won't get called unless we're on an ipad
		[self initializeDatabase];
#endif

		NSError *error = nil;
		if (![[self fetchedResultsController] performFetch:&error])
		{
			debug_NSLog(@"LinksMenuDataSource-init: Unresolved error %@, %@", error, [error userInfo]);
		}		
		else if ([self.fetchedResultsController.fetchedObjects count] == 0)
			debug_NSLog(@"No link resources in a database...");
			
	}
	return self;
}

- (void)dealloc {	
#if NEEDS_TO_INITIALIZE_DATABASE == 1 || JUST_INITIALIZE_LINKS == 1
	[linksData release];
#endif
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;

    [super dealloc];
}

#if NEEDS_TO_INITIALIZE_DATABASE == 1 || JUST_INITIALIZE_LINKS == 1
#warning initializeDatabase IS TURNED ON!!!
#warning DON'T FORGET TO LINK IN THE APPROPRIATE PLIST FILES

- (void) setupDataArray {
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
	
	if ([link.url isEqualToString:@"aboutView"]) {
		NSString *path = nil;
		if ([UtilityMethods isIPadDevice])
			path = [[NSBundle mainBundle] pathForResource:@"TexLegeInfo~ipad" ofType:@"htm"];
		else
			path = [[NSBundle mainBundle] pathForResource:@"TexLegeInfo~iphone" ofType:@"htm"];
		
		link.url = [NSString stringWithFormat:@"file://%@", path];
		
	}
	
	return link;	
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	return [self.fetchedResultsController indexPathForObject:dataObject];
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
		if (section == kHeaderSection) {
			cell.accessoryType = disclosure;
		}
		else {
			DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 25.f, 25.f)];
			//UIImageView *iv = [[UIImageView alloc] initWithImage:[qv imageFromUIView]];
			cell.accessoryView = qv;
			[qv release];
			//[iv release];			
		}

		
	}
	
	LinkObj *link = [self dataObjectForIndexPath:indexPath];
	if (link) {
		cell.textLabel.text = link.label;
		
		if (indexPath.section == kBodySection)
			cell.detailTextLabel.text = link.url;
	}
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
	
	/* This was so we could edit core data contents on the fly ... keep it for an example
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil) {
		debug_NSLog(@"There's no links objects ???");
	}
	for (LinkObj *object in fetchedObjects) {
		if ([object.section integerValue] == kHeaderSection) {
			if ([object.url isEqualToString:@"voteInfoView"]) {	// we've changed out this old thingy
				debug_NSLog(@"%@", object.url);
				object.url = @"contactMail";
				object.label = @"Contact TexLege Support";
				continue;
			}
		}
	}	
	[self saveAction:nil];
	*/
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:managedObjectContext
																								  sectionNameKeyPath:@"section" cacheName:@"LinksCache"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortSection release];
	[sortOrder release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

@end
