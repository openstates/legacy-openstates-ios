    //
//  CalendarMasterViewController.m
//  TexLege
//
//  Created by Gregory Combs on 8/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CalendarMasterViewController.h"
#import "UtilityMethods.h"

#import "TexLegeAppDelegate.h"
#import "TableDataSourceProtocol.h"

#import "CalendarDataSource.h"
#import "CalendarDetailViewController.h"

#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"

@implementation CalendarMasterViewController

- (void)loadView {
	[super runLoadView];
}

- (Class)dataSourceClass {
	return [CalendarDataSource class];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
		self.selectObjectOnAppear = [self firstDataObject];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
		
	if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = self.detailViewController ? [self.detailViewController valueForKey:@"chamberCalendar"] : nil;
		
		if (!detailObject) {
			NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
			if (!currentIndexPath) {			
				NSUInteger ints[2] = {0,0};	// just pick the first one then
				currentIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
			}
			detailObject = [self.dataSource dataObjectForIndexPath:currentIndexPath];			
		}
		self.selectObjectOnAppear = detailObject;
	}	
	if ([UtilityMethods isIPadDevice]) {
		self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
		[self.tableView reloadData]; // this "fixes" an issue where it's using cached (bogus) values for our vote index sliders
	}
	
}

#pragma -
#pragma UITableViewDelegate

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
		
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];
	// save off this item's selection to our AppDelegate

	[appDelegate setSavedTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
	
	if (!self.detailViewController) {
		CalendarDetailViewController *temp = [[CalendarDetailViewController alloc] initWithNibName:[CalendarDetailViewController nibName] 
																							bundle:nil];
		self.detailViewController = temp;
		[temp release];
	}
	
	if (!dataObject || ![dataObject isKindOfClass:[ChamberCalendarObj class]])
		return;
	
	ChamberCalendarObj *calendar = dataObject;
	
	if ([self.detailViewController respondsToSelector:@selector(setChamberCalendar:)])
		[self.detailViewController setValue:calendar forKey:@"chamberCalendar"];
	
	if (![UtilityMethods isIPadDevice]) {
		// push the detail view controller onto the navigation stack to display it
		((UIViewController *)self.detailViewController).hidesBottomBarWhenPushed = YES;
		
		[self.navigationController pushViewController:self.detailViewController animated:YES];
		self.detailViewController = nil;
	}		
}

// the *user* selected a row in the table, so turn on animations and save their selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	[super tableView:aTableView didSelectRowAtIndexPath:newIndexPath];
	
	// if we have a stack of view controllers and someone selected a new cell from our master list, 
	//	lets go all the way back to accomodate their selection, and scroll to the top.
	if ([UtilityMethods isIPadDevice]) {
		if ([self.detailViewController respondsToSelector:@selector(tableView)]) {
			UITableView *detailTable = [self.detailViewController performSelector:@selector(tableView)];
			[detailTable reloadData];		// don't we already do this in our own combo detail controller?
		}
	}
}

@end
