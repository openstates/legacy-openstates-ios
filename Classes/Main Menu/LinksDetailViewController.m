//
//  LinksDetailViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LinksDetailViewController.h"
#import "LinkObj.h"
#import "EditingTableViewCell.h"
#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"
 
@implementation LinksDetailViewController

@synthesize link, editingTableViewCell, fetchedResultsController;

#pragma mark -
#pragma mark View controller


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        UINavigationItem *navigationItem = self.navigationItem;
        navigationItem.title = @"Resource Link";

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];

        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style resultsController:(NSFetchedResultsController *)controller {
    if (self = [self initWithStyle:style]) {
		self.fetchedResultsController = controller;
    }
    return self;
}

/*
- (void)viewWillAppear:(BOOL)animated {
	[self showPopoverMenus:([UtilityMethods isLandscapeOrientation] == NO)];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LinkCellIdentifier = @"EditingLinkCell";
    
    EditingTableViewCell *cell = (EditingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:LinkCellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EditingTableViewCell" owner:self options:nil];
        cell = editingTableViewCell;
		self.editingTableViewCell = nil;
    }
    
	cell.textField.clearsOnBeginEditing = NO; // default to off
	cell.textField.keyboardType = UIKeyboardTypeDefault;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;	// we only edit text, we don't "select" the cell.

	
    if (indexPath.row == 0) {
        cell.label.text = @"Label";
        cell.textField.text = link.label;
        cell.textField.placeholder = @"Example Website";
		if (link.label.length == 0)
			cell.textField.clearsOnBeginEditing = YES;
    }
	else if (indexPath.row == 1) {
        cell.label.text = @"URL";
        cell.textField.text = link.url;
        cell.textField.placeholder = @"http://www.example.com";
		if (link.url.length == 0)
			cell.textField.clearsOnBeginEditing = YES;
		cell.textField.keyboardType = UIKeyboardTypeURL;
    }

    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark -
#pragma mark Save and cancel

- (void)save:(id)sender {
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	
	/*
	 If there isn't an existing link object, create and configure one.
	 */
    if (!link) {
        link = [NSEntityDescription insertNewObjectForEntityForName:@"LinkObj" inManagedObjectContext:context];

		NSArray *sections = [fetchedResultsController sections];
		NSUInteger count = 0;
		if ([sections count]) {
			id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:1];
			count = [sectionInfo numberOfObjects];
		}
		link.order = [NSNumber numberWithInteger:count];	// put it in our last row.
		link.section = [NSNumber numberWithInteger:1];
		link.timeStamp = [NSDate date];
	}
	
	/*
	 Update the link from the values in the text fields.
	 */
    EditingTableViewCell *cell;
	
    cell = (EditingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    link.label = cell.textField.text;
	
    cell = (EditingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    link.url = cell.textField.text;
	
	
	/*
	 Save the managed object context.
	 */
	NSError *error = nil;
	if (![context save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	[[self navigationController] popToRootViewControllerAnimated:YES];
	self.link = nil;
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	self.link = nil;
    [super dealloc];
}

@end
