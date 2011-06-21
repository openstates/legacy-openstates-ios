//
//  CapitolMapsDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "CapitolMapsDataSource.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "TexLegeStandardGroupCell.h"

@interface CapitolMapsDataSource(Private)

- (void)createSectionList;

@end

@implementation CapitolMapsDataSource

@synthesize sectionList;

// TableDataSourceProtocol methods

- (NSString *)name 
{ return NSLocalizedStringFromTable(@"Capitol Maps", @"StandardUI", @"The short title for buttons and tabs related to maps of the building"); }

- (NSString *)navigationBarName 
{ return [self name]; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"71-compass-inv.png"]; }

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
	if ((self = [super init])) {
		
		self.sectionList = [[[NSMutableArray alloc] init] autorelease];
		[self createSectionList];
	}
	return self;
}

- (void)dealloc {
	self.sectionList = nil;
	[super dealloc];
}


/* Build a list of files */
- (void)createSectionList {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CapitolMaps" ofType:@"plist"];
	NSArray *mapSectionsPlist = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	for (NSArray * section in mapSectionsPlist)
	{
		NSMutableArray *tempSection = [[NSMutableArray alloc] initWithCapacity:[section count]];

		for (NSDictionary * mapEntry in section)
		{
			CapitolMap *newMap = [[CapitolMap alloc] init];
			[newMap importFromDictionary:mapEntry];
			[tempSection addObject:newMap];
			[newMap release];
		}
		[self.sectionList addObject:tempSection];
		[tempSection release];
	}
	
	[mapSectionsPlist release];
	[pool drain];
}


// return the map at the index in the array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	NSArray *thisSection = [self.sectionList objectAtIndex:indexPath.section];
	if (thisSection)
		return [thisSection objectAtIndex:indexPath.row];
	
	return nil;
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	NSInteger section = 0;
	NSInteger row = 0;
	
	if (dataObject && [dataObject isKindOfClass:[CapitolMap class]]) {
		section = [[dataObject valueForKey:@"type"] integerValue];
		NSArray *thisSection = [self.sectionList objectAtIndex:section];
		if (thisSection) {
			row = [thisSection indexOfObject:dataObject];
			if (row == NSNotFound)
				row = 0;
		}
	}
	return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	static NSString *CellIdentifier = @"Cell";
	
	/* Look up cell in the table queue */
    TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.font = [TexLegeTheme boldFifteen];
    }
	BOOL useDark = (indexPath.row % 2 == 0);

	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
				
	cell.textLabel.text = [[self dataObjectForIndexPath:indexPath] name];
				 
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
		return NSLocalizedStringFromTable(@"Interior Maps", @"DataTableUI", @"Cell title for interor maps of a building (office locations)");
	else //if (section == 1)
		return NSLocalizedStringFromTable(@"Exterior Maps", @"DataTableUI", @"Cell title for outside maps of a building (outdoor locations)");
}

@end
