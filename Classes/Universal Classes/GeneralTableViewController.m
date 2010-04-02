/*

File: GeneralTableViewController.m
Abstract: Coordinates the tableviews and element data sources. It also responds
 to changes of selection in the table view and provides the cells.

Version: 1.7

*/

#import "GeneralTableViewController.h"

#import "AtomicElement.h"
#import "AtomicElementTableViewCell.h"
#import "DetailTableViewController.h"
#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"


@implementation GeneralTableViewController

@synthesize theTableView;
@synthesize dataSource;
 

// this is the custom initialization method for the GeneralTableViewController
// it expects an object that conforms to both the UITableViewDataSource protocol
// which provides data to the tableview, and the ElementDataSource protocol which
// provides information about the elements data that is displayed,
- (id)initWithDataSource:(id<TableDataSource,UITableViewDataSource>)theDataSource {
	if ([self init]) {
		theTableView = nil;
		
		// retain the data source
		self.dataSource = theDataSource;
		// set the title, and tab bar images from the dataSource
		// object. These are part of the TableDataSource Protocol
		self.title = [dataSource name];
		self.tabBarItem.image = [dataSource tabBarImage];

		// set the long name shown in the navigation bar
		self.navigationItem.title=[dataSource navigationBarName];

		// create a custom navigation bar button and set it to always say "back"
		UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
		temporaryBarButtonItem.title=@"Back";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		[temporaryBarButtonItem release];
		
	}
	return self;
}


- (void)dealloc {
	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	[theTableView release];
	[dataSource release];
	[super dealloc];
}


- (void)loadView {
	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[dataSource tableViewStyle]];
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the cell separator to a single straight line.
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = dataSource;
	
	tableView.sectionIndexMinimumDisplayRowCount=10;

	// set the tableview as the controller view
    self.theTableView = tableView;
	self.view = tableView;
	[tableView release];

}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load

	[theTableView reloadData];
}


//
//
// UITableViewDelegate methods
//
//

// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
    [tableView deselectRowAtIndexPath:newIndexPath animated:YES];	
 
	// create an DetailTableViewController. This controller will display the full size tile for the element
	DetailTableViewController *detailController = [[DetailTableViewController alloc] init];

	if (dataSource.name == @"Maps")
	{
		detailController.mapFileName = [dataSource cellImageDataForIndexPath:newIndexPath];
	}
	else {
		// set/get the element that is represented by the selected row.
		detailController.element = [dataSource cellDataForIndexPath:newIndexPath];
	}
	
	// push the detail view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:detailController animated:YES];
	[detailController release];
}


@end
