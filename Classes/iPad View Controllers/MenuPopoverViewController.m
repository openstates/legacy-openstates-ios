//
//  MenuPopoverViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "MenuPopoverViewController.h"
#import "TableDataSourceProtocol.h"

@interface MenuPopoverViewController (Private)

@property (nonatomic, readonly) NSArray *functionalViewControllers;

- (void) showOrHideItemPopover:(UIViewController *) itemViewController fromRect:(CGRect)clickedRow;

@end

@implementation MenuPopoverViewController

@synthesize itemPopoverController, voteInfoViewController, aboutViewController, appDelegate;

- (NSArray *) functionalViewControllers {
	NSArray * viewControllers = nil;
	
	if ([self.appDelegate respondsToSelector:@selector(functionalViewControllers)])
		viewControllers = [self.appDelegate performSelector:@selector(functionalViewControllers)];
	else 
		viewControllers = [NSArray array];
	
	return viewControllers;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.appDelegate = (TexLegeAppDelegate *)[[UIApplication sharedApplication] delegate];


	self.itemPopoverController = nil;
	
	self.aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	self.aboutViewController.delegate = self;

	self.voteInfoViewController = [[VoteInfoViewController alloc] initWithNibName:@"VoteInfoView" bundle:nil];
	self.voteInfoViewController.delegate = self;
	
	self.contentSizeForViewInPopover = CGSizeMake(300.0, 450.0);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.appDelegate = nil;
	self.itemPopoverController = nil;
	self.aboutViewController = nil;
	self.voteInfoViewController = nil;
}


- (void)dealloc {
    [super dealloc];
	
	//self.itemPopoverController = nil;
}


#pragma mark -
#pragma mark Screen Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 1)
		return 2;
	else
		return [self.functionalViewControllers count];	
}

- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = nil;
	NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;
	
	if (section == 1) {
		if (row == 0)
			object = self.aboutViewController;
		else 
			object = self.voteInfoViewController;
	}
	else
		object = [self.functionalViewControllers objectAtIndex:row];
	
	return object;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	id object = [self objectForRowAtIndexPath:indexPath];
	
    cell.textLabel.textColor = [UIColor whiteColor];
	if ([object respondsToSelector:@selector(title)])
		cell.textLabel.text = [object performSelector:@selector(title)];
	
	if ([object respondsToSelector:@selector(dataSource)]) {
		id<TableDataSource> selectedSource = [object performSelector:@selector(dataSource)];
		if ([selectedSource respondsToSelector:@selector(tabBarImage)])
			cell.imageView.image = [selectedSource performSelector:@selector(tabBarImage)];
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	if (section == 0)
		return @"";
	else //(section == 1)
		return @"Application Info";	
}


- (void) showOrHideItemPopover:(UIViewController *) itemViewController fromRect:(CGRect)clickedRow {
	if (self.itemPopoverController) {
		itemViewController.modalInPopover = NO;
		[self modalViewControllerDidFinish:itemViewController];
	}
	else {
		itemViewController.modalInPopover = YES;

		self.itemPopoverController = [[UIPopoverController alloc] initWithContentViewController:itemViewController];
		self.itemPopoverController.popoverContentSize = itemViewController.view.frame.size;
		self.itemPopoverController.delegate = self;
		[self.itemPopoverController presentPopoverFromRect:clickedRow inView:self.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	
}

- (void)modalViewControllerDidFinish:(UIViewController *)controller {
	if (self.itemPopoverController) {
        [self.itemPopoverController dismissPopoverAnimated:YES];
		self.itemPopoverController = nil;
	}
}
		
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// the user (not us) has dismissed the popover, let's cleanup.
	self.itemPopoverController = nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//[appDelegate showOrHideMenuPopover:nil];

	if (section == 1) {
		CGRect clickedRow = [tableView rectForRowAtIndexPath:indexPath];

		[self showOrHideItemPopover:[self objectForRowAtIndexPath:indexPath] fromRect:clickedRow];
	}
	else {

		[appDelegate showOrHideMenuPopover:nil];
	}
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


@end

