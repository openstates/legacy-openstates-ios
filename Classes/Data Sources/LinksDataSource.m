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
		if (newContext) 
			managedObjectContext = [newContext retain];
	
		//NSError *error = nil;
		/*if (![self.fetchedResultsController performFetch:&error])
		{
			debug_NSLog(@"LinksMenuDataSource-init: Unresolved error %@, %@", error, [error userInfo]);
		}*/		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];		
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;	
    [super dealloc];
}

-(void)dataSourceReceivedMemoryWarning:(id)sender {
	// let's give this a swinging shot....	
	for (NSManagedObject *object in self.fetchedResultsController.fetchedObjects) {
		[self.managedObjectContext refreshObject:object mergeChanges:NO];
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
		return @"This Application";
	else
		return @"Web Resources";		
}

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	LinkObj * link = [self.fetchedResultsController objectAtIndexPath:indexPath];	
	
	if ([link.url isEqualToString:@"aboutView"]) {
		NSString *path = nil;
		if ([UtilityMethods isIPadDevice])
			path = [[NSBundle mainBundle] pathForResource:@"TexLegeInfo~ipad" ofType:@"htm"];
		else
			path = [[NSBundle mainBundle] pathForResource:@"TexLegeInfo~iphone" ofType:@"htm"];
		
		path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString *urlString = [[NSString alloc] initWithFormat:@"file://%@", path];
		link.url = urlString;
		[urlString release];
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
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:managedObjectContext
																								  sectionNameKeyPath:@"section" cacheName:@"Links"];
	fetchedResultsController.delegate = self;
	
	[fetchRequest release];
	[sortSection release];
	[sortOrder release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

@end
