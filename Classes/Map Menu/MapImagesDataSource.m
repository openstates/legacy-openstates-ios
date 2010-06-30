//
//  MapImagesDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "MapImagesDataSource.h"
#import "TexLegeAppDelegate.h"

@implementation MapImagesDataSource

@synthesize managedObjectContext;
//@synthesize fetchedResultsController;

@synthesize InteriorMaps;
@synthesize ExteriorMaps;
@synthesize ChamberMaps;

// TableDataSourceProtocol methods

- (NSString *)navigationBarName
{ return @"Capitol Maps"; }

- (NSString *)name
{ return @"Maps"; }
 
- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"71-compass.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)usesToolbar
{ return NO; }

- (BOOL)usesSearchbar
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
		[self reload];
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init])
		if (newContext) self.managedObjectContext = newContext;
	return self;
}


/* Build a list of files */
- (void)reload {
	InteriorMaps = [[NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"Fourth Floor", @"Map.Floor4.pdf",nil],
					 [NSArray arrayWithObjects:@"Third Floor", @"Map.Floor3.pdf",nil],
					 [NSArray arrayWithObjects:@"Second Floor", @"Map.Floor2.pdf",nil],
					 [NSArray arrayWithObjects:@"First Floor", @"Map.Floor1.pdf",nil],
					 [NSArray arrayWithObjects:@"Ground Floor", @"Map.FloorG.pdf",nil],
					 [NSArray arrayWithObjects:@"Extension 1st Floor (E1)", @"Map.FloorE1.pdf",nil],
					 [NSArray arrayWithObjects:@"Extension 2nd Floor (E2)", @"Map.FloorE2.pdf",nil],
					 nil]
					 retain];

	ExteriorMaps = [[NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"Capitol Complex", @"Map.CapitolComplex.pdf",nil],
					 [NSArray arrayWithObjects:@"Wheelchair Access", @"Map.WheelchairAccess.pdf",nil],
					 [NSArray arrayWithObjects:@"Monument Guide", @"Map.MonumentGuide.pdf",nil],
					 nil]
					retain];
	
	ChamberMaps = [[NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"House Chamber", @"Map.HouseChamber.pdf",nil],
					 [NSArray arrayWithObjects:@"Senate Chamber", @"Map.SenateChamber.pdf",nil],
					 nil]
					retain];
	
}

// return an image file name
- (NSString *)cellImageDataForIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = nil;
	
	if (indexPath.section == 0) // Get the file name for our interior map
		CellIdentifier = [[[InteriorMaps objectAtIndex:indexPath.row] objectAtIndex:1] autorelease];
	
	else if (indexPath.section == 1) // Get the file name for our exterior map
		CellIdentifier = [[[ExteriorMaps objectAtIndex:indexPath.row] objectAtIndex:1] autorelease];

	else if (indexPath.section == 2) // Get the file name for our exterior map
		CellIdentifier = [[[ChamberMaps objectAtIndex:indexPath.row] objectAtIndex:1] autorelease];

	return CellIdentifier;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	NSString *CellIdentifier = nil;
	
	if (indexPath.section == 0) // Get the proper name for our interior map
		CellIdentifier = [[InteriorMaps objectAtIndex:indexPath.row] objectAtIndex:0];
	
	else if (indexPath.section == 1) // Get the proper name for our exterior map
		CellIdentifier = [[ExteriorMaps objectAtIndex:indexPath.row] objectAtIndex:0];

	else if (indexPath.section == 2) // Get the proper name for our exterior map
		CellIdentifier = [[ChamberMaps objectAtIndex:indexPath.row] objectAtIndex:0];

	    
	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// configure cell contents
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = CellIdentifier;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Three sections
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {		

 NSInteger rows = 0;
	
	if (section == 0)
		rows = [InteriorMaps count];
	else if (section == 1)
		rows = [ExteriorMaps count];
	else if (section == 2)
		rows = [ChamberMaps count];
	return rows;
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
	[ InteriorMaps release ], InteriorMaps = nil;
	[ ExteriorMaps release ], ExteriorMaps = nil;
	[ ChamberMaps release ], ChamberMaps = nil;

	//[fetchedResultsController release];
	self.managedObjectContext = nil;
	[super dealloc];
}
@end
