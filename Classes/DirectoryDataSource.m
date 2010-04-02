/*

File: DirectoryDataSource.m
Abstract: Provides the table view data for the legislator directory.

Version: 1.0

*/

#import "DirectoryDataSource.h"
#import "TexLegeAppDelegate.h"

#import "DetailTableViewController.h"
#import "LegislatorsListing.h"


@implementation DirectoryDataSource

 
// TableDataSourceProtocol methods

// return the data used by the navigation controller and tab bar item

- (NSString *)name {
	return @"Directory";
}

- (NSString *)navigationBarName {
	return @"Legislator Directory";
}

- (UIImage *)tabBarImage {
	return [UIImage imageNamed:@"Directory.png"];
}

- (BOOL)showDisclosureIcon
{
	return YES;
}

// legislator name is displayed in a plain style tableview

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
};

// return the legislator  at the index 
- (Legislator *)legislatorDataForIndexPath:(NSIndexPath *)indexPath {
	return [[[LegislatorsListing sharedLegislators] legislatorsWithInitialLetter:[[[LegislatorsListing sharedLegislators] legislatorNameIndexArray] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	static NSString *MyIdentifier = @"LegislatorDirectory";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame: CGRectZero reuseIdentifier: MyIdentifier] autorelease];
	}
   
	// configure cell contents
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textAlignment = UITextAlignmentLeft;

	// set the legislator for this cell as specified by the datasource. The legislatorDataForIndexPath: is declared
	// as part of the TableDataSource Protocol and will return the appropriate legislator for the index row
	Legislator * tempLegislator = [self legislatorDataForIndexPath:indexPath];
	cell.text = tempLegislator.description;

	return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// this table has multiple sections. One for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	// return the count of that array
	return [[[LegislatorsListing sharedLegislators] legislatorNameIndexArray] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	// returns the array of section titles. There is one entry for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	return [[LegislatorsListing sharedLegislators] legislatorNameIndexArray];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	// the section represents the initial letter of the element
	// return that letter
	NSString *initialLetter = [[[LegislatorsListing sharedLegislators] legislatorNameIndexArray] objectAtIndex:section];
	
	// get the array of elements that begin with that letter
	NSArray *legislatorsWithInitialLetter = [[LegislatorsListing sharedLegislators] legislatorsWithInitialLetter:initialLetter];
	
	// return the count
	return [legislatorsWithInitialLetter count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each unique character that an element begins with
	// [A,B,C,D,E,F,G,H,I,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z]
	// return the letter that represents the requested section
	// this is actually a delegate method, but we forward the request to the datasource in the view controller
	
	return [[[LegislatorsListing sharedLegislators] legislatorNameIndexArray] objectAtIndex:section];
}



@end
