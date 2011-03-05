//
//  BillsMenuDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 2/16/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsMenuDataSource.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "TexLegeAppDelegate.h"

@implementation BillsMenuDataSource

@synthesize menuItems = _menuItems/*, searchDisplayController*/;

enum _menuOrder {
	kMenuFavorites = 0,
	kMenuKeyBills,
	kMenuRecent,
	kMenuCategories,
	kMenuLASTITEM
};

// TableDataSourceProtocol methods

- (NSString *)navigationBarName
{ return @"Bills"; }

- (NSString *)name
{ return @"Bills"; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"gavel.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)canEdit
{ return NO; }

- (NSManagedObjectContext *)managedObjectContext {
	return nil;
}

// displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[_menuItems release];
	//self.searchDisplayController = nil;
	[super dealloc];
}


/* Build a list of files */
- (NSArray *)menuItems {
	if (!_menuItems) {
			
		NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
		NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
		_menuItems = [[textDict objectForKey:@"BillMenuItems"] retain];
		
		if (!_menuItems)
			_menuItems = [[[NSArray alloc] init] retain];
	}
	return _menuItems;
}


// return the map at the index in the array
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	return [self.menuItems objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {	
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];

	if (dataObject) {
		NSString *theClass = nil;
		if ([dataObject isKindOfClass:[NSDictionary class]])
			theClass = [dataObject objectForKey:@"class"];
		else if ([dataObject isKindOfClass:[NSString class]])
			theClass = dataObject;
		
		NSInteger row = 0;
		for (NSDictionary *object in self.menuItems) {
			if ([theClass isEqualToString:[object objectForKey:@"class"]])
				path = [NSIndexPath indexPathForRow:row inSection:0];
			row++;
		}		
	}
	return path;
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
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
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
	
///	cell.accessoryView.hidden = (![self showDisclosureIcon] || tableView == self.searchDisplayController.searchResultsTableView);

	NSDictionary *dataObject = [self dataObjectForIndexPath:indexPath];
	cell.textLabel.text = [dataObject objectForKey:@"title"];
	cell.imageView.image = [UIImage imageNamed:[dataObject objectForKey:@"icon"]];

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [self.menuItems count];
}

@end
