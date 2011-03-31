//
//  BillsListDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsListDetailViewController.h"
#import "TexLegeAppDelegate.h"
#import "BillsDetailViewController.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"
#import "BillSearchDataSource.h"
#import "OpenLegislativeAPIs.h"

@interface BillsListDetailViewController (Private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BillsListDetailViewController
@synthesize dataSource;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		dataSource = [[[BillSearchDataSource alloc] initWithTableViewController:self] retain];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([UtilityMethods isIPadDevice] && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		if ([[[[TexLegeAppDelegate appDelegate] masterNavigationController] topViewController] isKindOfClass:[BillsListDetailViewController class]])
			if ([self.navigationController isEqual:[[TexLegeAppDelegate appDelegate] detailNavigationController]])
				[self.navigationController popToRootViewControllerAnimated:YES];
		
	}	
}

- (void)didReceiveMemoryWarning {
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>1)
		[nav popToRootViewControllerAnimated:YES];
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {	
	
	[dataSource release];
	
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self.dataSource;
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

/*- (void)viewWillDisappear:(BOOL)animated {
 //	[self save:nil];
 [super viewWillDisappear:animated];
 }*/

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![UtilityMethods isIPadDevice])
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *bill = [dataSource dataObjectForIndexPath:indexPath];
	if (bill && [bill objectForKey:@"bill_id"]) {
		if (bill) {
						
			BOOL changingViews = NO;
			
			BillsDetailViewController *detailView = nil;
			if ([UtilityMethods isIPadDevice]) {
				id aDetail = [[[TexLegeAppDelegate appDelegate] detailNavigationController] visibleViewController];
				if ([aDetail isKindOfClass:[BillsDetailViewController class]])
					detailView = aDetail;
			}
			if (!detailView) {
				detailView = [[[BillsDetailViewController alloc] 
							   initWithNibName:@"BillsDetailViewController" bundle:nil] autorelease];
				changingViews = YES;
			}
			
			[detailView setDataObject:bill];
			[[OpenLegislativeAPIs sharedOpenLegislativeAPIs] queryOpenStatesBillWithID:[bill objectForKey:@"bill_id"] 
																			   session:[bill objectForKey:@"session"] 
																			  delegate:detailView];
			
			if (![UtilityMethods isIPadDevice])
				[self.navigationController pushViewController:detailView animated:YES];
			else if (changingViews)
				//[[[self.splitViewController viewControllers] objectAtIndex:1] pushViewController:detailView animated:YES];
				[[[TexLegeAppDelegate appDelegate] detailNavigationController] pushViewController:detailView animated:YES];
				///[[[TexLegeAppDelegate appDelegate] detailNavigationController] setViewControllers:[NSArray arrayWithObject:detailView] animated:NO];
		}			
	}
}

@end



