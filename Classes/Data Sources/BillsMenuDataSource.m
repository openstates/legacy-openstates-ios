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

@interface BillsMenuDataSource (Private)
- (void)createSectionList;
@end

@implementation BillsMenuDataSource

@synthesize managedObjectContext, sectionList;

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


// displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if (self = [super init]) {
		if (newContext) 
			managedObjectContext = [newContext retain];
		
		self.sectionList = [[[NSMutableArray alloc] init] autorelease];
		[self createSectionList];
	}
	return self;
}

- (void)dealloc {
	self.sectionList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}


/* Build a list of files */
- (void)createSectionList {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSArray *menuItems = [textDict objectForKey:@"BillMenuItems"];
	
	if (menuItems && [menuItems count]) {
		[self.sectionList removeAllObjects];
		if ([menuItems count] != kMenuLASTITEM) {
			NSLog(@"Something's wrong with the bill menu");
			[pool drain];
			return;
		}
	}
	
	NSArray *classes = [[NSArray alloc] initWithObjects:
						@"BillsFavoritesViewController",
						"BillsKeyViewController", 
						"BillsRecentViewController",
						"BillsCategoriesViewController",
						nil];
	// use the following:
	//		[[NSClassFromString(className) alloc] initWithSomething:stuff];
	
	for (NSInteger index = 0; index < kMenuLASTITEM; index++) {
		NSDictionary *itemDict = [[NSDictionary alloc] initWithObjectsAndKeys:
								  @"BillsMenuItem", @"dataObject",
								  [menuItems objectAtIndex:index], @"title",
								  [classes objectAtIndex:index], @"class",
								  nil];
		[self.sectionList addObject:itemDict];
		[itemDict release];
	}
	[classes release];
		
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
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];

	if (dataObject) {
		NSString *theClass = nil;
		if ([dataObject isKindOfClass:[NSDictionary class]])
			theClass = [dataObject objectForKey:@"class"];
		else if ([dataObject isKindOfClass:[NSString class]])
			theClass = dataObject;
		
		NSInteger row = 0;
		for (NSDictionary *object in self.sectionList) {
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
	
	cell.textLabel.text = [[self dataObjectForIndexPath:indexPath] objectForKey:@"title"];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [self.sectionList count];
}

@end
