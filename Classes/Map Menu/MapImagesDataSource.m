/*

File: MapImagesDataSource.m
Abstract: Provides the table view data for the capitol maps.

Version: 1.0

*/

#import "MapImagesDataSource.h"
#import "TexLegeAppDelegate.h"
#import "AtomicElement.h"


@implementation MapImagesDataSource

@synthesize InteriorMaps;
@synthesize ExteriorMaps;

// TableDataSourceProtocol methods

// return the data used by the navigation controller and tab bar item
- (NSString *)navigationBarName {
	return @"Capitol Maps";
}

- (NSString *)name {
	return @"Maps";
}

 
- (UIImage *)tabBarImage {
	return [UIImage imageNamed:@"71-compass.png"];
}


- (BOOL)showDisclosureIcon
{
	return YES;
}


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

/* Build a list of files */
- (void)reload {
	InteriorMaps = [[NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"Floors 4, 3, & 2", @"Map.Floors234.pdf",nil],
					 [NSArray arrayWithObjects:@"Floors 1 and Ground", @"Map.Floors1andGround.pdf",nil],
					 [NSArray arrayWithObjects:@"Extension 1st Floor (E1)", @"Map.ExtensionF1.pdf",nil],
					 [NSArray arrayWithObjects:@"Extension 2nd Floor (E2)", @"Map.ExtensionF2.pdf",nil],
					 nil]
					 retain];

	ExteriorMaps = [[NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"Capitol Complex", @"Map.CapitolComplex.pdf",nil],
					 [NSArray arrayWithObjects:@"Wheelchair Access", @"Map.WheelchairAccess.pdf",nil],
					 [NSArray arrayWithObjects:@"Monument Guide", @"Map.MonumentGuide.pdf",nil],
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
	
	return CellIdentifier;
}

// return the atomic element at the index in the sorted by symbol array
- (AtomicElement *)cellDataForIndexPath:(NSIndexPath *)indexPath {
	// Don't care, we're not using Atomic crap.
	return nil;
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
	
	    
	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// configure cell contents
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.text = CellIdentifier;
	cell.textAlignment = UITextAlignmentLeft;
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Just Interior & Exterior Map sections
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {		

 NSInteger rows = 0;
	
	if (section == 0)
		rows = [InteriorMaps count];
	else if (section == 1)
		rows = [ExteriorMaps count];
	return rows;
}



 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	if (section == 1)
		return @"Exterior Maps";
	else
		return @"Interior Maps";
}


- (void)dealloc {
	[ InteriorMaps release ];
	[ ExteriorMaps release ];

	[super dealloc];
}
@end
