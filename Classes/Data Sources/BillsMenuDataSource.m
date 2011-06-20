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
#import "TexLegeStandardGroupCell.h"
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
#warning localization

// TableDataSourceProtocol methods

// return the data used by the navigation controller and tab bar item
- (NSString *)name
{ return NSLocalizedStringFromTable(@"Bills", @"StandardUI", @"Short name for bills (legislative documents, pre-law) tab"); }

- (NSString *)navigationBarName 
{ return [self name]; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"gavel.png"]; }

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
			_menuItems = [[NSArray alloc] init];
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
    TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.font = [TexLegeTheme boldFifteen];				
    }
	BOOL useDark = (indexPath.row % 2 == 0);
	
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
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
