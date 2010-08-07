//
//  CapitolMapsDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CapitolMapsDataSource.h"
#import "TexLegeAppDelegate.h"

@interface CapitolMapsDataSource(Private)

- (void)createSectionList;

@end

@implementation CapitolMapsDataSource

@synthesize managedObjectContext, sectionList;

// TableDataSourceProtocol methods

- (NSString *)navigationBarName
{ return @"Capitol Maps"; }

- (NSString *)name
{ return @"Maps"; }
 
- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"71-compass"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)canEdit
{ return NO; }


// displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (id)init {
	self = [super init];
	if (self !=nil) {
		/* Build a list of files */		
		self.sectionList = [[NSMutableArray alloc] init];
		[self createSectionList];
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init])
		if (newContext) self.managedObjectContext = newContext;
	return self;
}


/* Build a list of files */
- (void)createSectionList {
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CapitolMaps" ofType:@"plist"];
	NSArray *mapSectionsPlist = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	for (NSArray * section in mapSectionsPlist)
	{
		NSMutableArray *tempSection = [NSMutableArray array];

		for (NSDictionary * mapEntry in section)
		{
			CapitolMap *newMap = [[[CapitolMap alloc] initWithDictionary:mapEntry] autorelease];
			[tempSection addObject:newMap];
			//[newMap release];
		}
		[self.sectionList addObject:tempSection];
	}
	
	[mapSectionsPlist release];
}


// Returns an array of the appropriate map ... [0] is the name [1] is just the file name (not path)
- (CapitolMap *)capitolMapForIndexPath:(NSIndexPath *)indexPath {	
	NSArray *thisSection = [self.sectionList objectAtIndex:indexPath.section];
	CapitolMap *capMap = [thisSection objectAtIndex:indexPath.row];
	return capMap;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	static NSString *CellIdentifier = @"Cell";
	
	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// configure cell contents
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = [[self capitolMapForIndexPath:indexPath] name];
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Three sections
	return [self.sectionList count];
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [[self.sectionList objectAtIndex:section] count];
}

 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	if (section == 0)
		return @"Interior Maps";
	else if (section == 1)
		return @"Exterior Maps";
	else // if (section == 3)
		return @"Chamber Floor Desk Maps";
}


- (void)dealloc {
	self.sectionList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}



@end
