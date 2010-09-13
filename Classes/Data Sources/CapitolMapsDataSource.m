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
#import "DisclosureQuartzView.h"

@interface CapitolMapsDataSource(Private)

- (void)createSectionList;

@end

@implementation CapitolMapsDataSource

@synthesize managedObjectContext, sectionList;

// TableDataSourceProtocol methods

- (NSString *)navigationBarName
{ return @"Capitol Maps"; }

- (NSString *)name
{ return @"Capitol Maps"; }
 
- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"71-compass.png"]; }

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

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext) self.managedObjectContext = newContext;
		
		self.sectionList = [[[NSMutableArray alloc] init] autorelease];
		[self createSectionList];
	}
	return self;
}


/* Build a list of files */
- (void)createSectionList {
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CapitolMaps" ofType:@"plist"];
	NSArray *mapSectionsPlist = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	for (NSArray * section in mapSectionsPlist)
	{
		NSMutableArray *tempSection = [[NSMutableArray alloc] initWithCapacity:[section count]];

		for (NSDictionary * mapEntry in section)
		{
			CapitolMap *newMap = [[CapitolMap alloc] initWithDictionary:mapEntry];
			[tempSection addObject:newMap];
			[newMap release];
		}
		[self.sectionList addObject:tempSection];
		[tempSection release];
	}
	
	[mapSectionsPlist release];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];

		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 12.0f;
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		//cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 25.f, 25.f)];
		//UIImageView *iv = [[UIImageView alloc] initWithImage:[qv imageFromUIView]];
		cell.accessoryView = qv;
		[qv release];
		//[iv release];
		
		
    }
	BOOL useDark = (indexPath.row % 2 == 0);

	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
			
	// configure cell contents
	//if ([self showDisclosureIcon])
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
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
		return @"Interior Maps";
	else //if (section == 1)
		return @"Exterior Maps";
}


- (void)dealloc {
	self.sectionList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}



@end
