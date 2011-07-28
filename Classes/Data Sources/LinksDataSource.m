//
//  LinksMenuDataSource.m
//  Created by Gregory S. Combs on 5/24/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LinksDataSource.h"
#import "UtilityMethods.h"
#import "TexLegeStandardGroupCell.h"
#import "TexLegeTheme.h"
#import "JSONKit.h"

@implementation LinksDataSource

enum Sections {
    kHeaderSection = 0,
    kBodySection,
    NUM_SECTIONS
};

@synthesize items = _items;

#pragma mark -
#pragma mark TableDataSourceProtocol methods

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)canEdit
{ return YES; }

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
} 

- (id)init {
	if ((self = [super init])) {
	
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataSourceReceivedMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];	

		NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"LinkObj" ofType:@"json"];
		NSData *jsonData = [NSData dataWithContentsOfFile:thePath];
		_items = [[jsonData mutableObjectFromJSONData] retain];
		NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
		[_items sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
		
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.items = nil;
    [super dealloc];
}

-(void)dataSourceReceivedMemoryWarning:(id)sender {
	// let's give this a swinging shot....	
}

#pragma mark -
#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 0;
	if (!IsEmpty(_items)) {
		NSArray *sub = [_items findAllWhereKeyPath:@"section" equals:[NSNumber numberWithInt:section]];
		if (sub) {
			rows = [sub count];
		}
	}
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == kHeaderSection)
		return NSLocalizedStringFromTable(@"This Application", @"DataTableUI", @"Table section listing resources for this application");
	else
		return NSLocalizedStringFromTable(@"Web Resources", @"DataTableUI", @"Table section listing resources on the web");		
}

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *object = nil;
	if (!IsEmpty(_items)) {
		NSInteger row = indexPath.row;
		NSInteger section = indexPath.section;
		
		NSArray *sub = [_items findAllWhereKeyPath:@"section" equals:[NSNumber numberWithInt:section]];
		if (sub && [sub count] > row)
			object = [sub objectAtIndex:row];
	}
	return object;	
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	NSIndexPath *tempIndex = nil;
	@try {
		NSInteger row = NSNotFound;
		NSInteger section = [[dataObject valueForKey:@"section"] integerValue];
		NSArray *sub = [_items findAllWhereKeyPath:@"section" equals:[NSNumber numberWithInt:section]];
		if (!IsEmpty(sub)) {
			row = [sub indexOfObject:dataObject];
			
			if (row != NSNotFound) {
				tempIndex = [NSIndexPath indexPathForRow:row inSection:section]; 
			}
		}
	}
	@catch (NSException * e) {
	}
	
	return tempIndex;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger section = indexPath.section;
	
	NSString *CellIdentifier = @"Cell";

	if (section == kHeaderSection)
		CellIdentifier = @"LinksHeader";
	else
		CellIdentifier = @"LinksBodyLink";
	
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{		
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
		if (section == kHeaderSection) {
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}		
		
		cell.textLabel.font = [TexLegeTheme boldFifteen];
		cell.textLabel.textColor = [TexLegeTheme textDark];
		cell.detailTextLabel.textColor = [TexLegeTheme indexText];
	}
	
	NSDictionary *link = [self dataObjectForIndexPath:indexPath];
	if (link) {
		cell.textLabel.text = [link valueForKey:@"label"];
		
		if (indexPath.section == kBodySection)
			cell.detailTextLabel.text = [link valueForKey:@"url"];
	}
	return cell;
}
	
+ (NSURL *) actualURLForURLString:(NSString *)urlString {	
	NSURL * actualURL = nil;
	
	if ([urlString isEqualToString:@"aboutView"]) {
		NSString *file = nil;
		
		if ([UtilityMethods isIPadDevice])
			file = @"TexLegeInfo~ipad.htm";
		else
			file = @"TexLegeInfo~iphone.htm";
		
		NSURL *baseURL = [UtilityMethods urlToMainBundle];
		actualURL = [NSURL URLWithString:file relativeToURL:baseURL];
	}
	else if ([urlString hasPrefix:@"mailto:"]) {
		actualURL = nil;
	}
	else if (urlString) {
		actualURL = [NSURL URLWithString:urlString];
	}
	
	return actualURL;	
}

@end
