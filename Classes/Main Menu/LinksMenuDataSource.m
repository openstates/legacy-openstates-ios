/*

File: MainMenuDataSource.m
Abstract: Provides the table view data for the elements sorted by their standard
physical state.

Version: 1.7

*/

#import "MainMenuDataSource.h"
#import "TexLegeAppDelegate.h"
#import "PeriodicElements.h"
#import "AtomicElement.h"
#import "AtomicElementTableViewCell.h"

@implementation MainMenuDataSource

// TableDataSourceProtocol methods


// return the data used by the navigation controller and tab bar item

- (NSString *)name {
	return @"Main";
}

- (NSString *)navigationBarName {
	return @"TexLege Main Menu";
}

- (UIImage *)tabBarImage {
	return [UIImage imageNamed:@"33-cabinet.png"];
}

- (BOOL)showDisclosureIcon
{
	return YES;
}


// atomic state is displayed in a grouped style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
} 

// return the atomic element at the index 
- (AtomicElement *)cellDataForIndexPath:(NSIndexPath *)indexPath {
	
	// this table has multiple sections. One for each physical state
	// [solid, liquid, gas, artificial]
	// the section represents the index in the state array
	// the row the index into the array of data for a particular state
	
	// get the state
	NSString *elementState = [[[PeriodicElements sharedPeriodicElements] elementPhysicalStatesArray] objectAtIndex:indexPath.section];
	
	// return the element in the state array
	return [[[PeriodicElements sharedPeriodicElements] elementsWithPhysicalState:elementState] objectAtIndex:indexPath.row];
}


// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AtomicElementTableViewCell *cell = (AtomicElementTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AtomicElementTableViewCell"];
	if (cell == nil) {
		cell = [[[AtomicElementTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AtomicElementTableViewCell"] autorelease];
	}
    
	// configure cell contents
	// all the rows should show the disclosure indicator
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// set the element for this cell as specified by the datasource. The cellDataForIndexPath: is declared
	// as part of the TableDataSource Protocol and will return the appropriate element for the index row
	cell.element = [self cellDataForIndexPath:indexPath];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
	// this table has multiple sections. One for each physical state
	// [solid, liquid, gas, artificial]
	// return the number of items in the states array
	return [[[PeriodicElements sharedPeriodicElements] elementPhysicalStatesArray] count];
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	// this table has multiple sections. One for each physical state
	// [solid, liquid, gas, artificial]
	
	// get the state key for the requested section
	NSString *stateKey = [[[PeriodicElements sharedPeriodicElements] elementPhysicalStatesArray] objectAtIndex:section];
	
	// return the number of items that are in the array for that state
	return [[[PeriodicElements sharedPeriodicElements] elementsWithPhysicalState:stateKey] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each physical state
	
	// [solid, liquid, gas, artificial]
	// return the state that represents the requested section
	// this is actually a delegate method, but we forward the request to the datasource in the view controller
	
	return [[[PeriodicElements sharedPeriodicElements] elementPhysicalStatesArray] objectAtIndex:section];
}


@end
