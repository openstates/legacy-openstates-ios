    //
//  CalendarMasterViewController.m
//  Created by Gregory Combs on 8/13/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CalendarMasterViewController.h"
#import "CalendarDataSource.h"
#import "ChamberCalendarObj.h"

#import "UtilityMethods.h"

#import "SLFPersistenceManager.h"
#import "TableDataSourceProtocol.h"

#import "CalendarDetailViewController.h"

#import "TexLegeTheme.h"
#import "SLFEmailComposer.h"

@implementation CalendarMasterViewController

#pragma mark -
#pragma mark Main Menu Info

+ (NSString *)name
{ return NSLocalizedStringFromTable(@"Events", @"StandardUI", @"The short title for buttons and tabs related to committee meetings (or calendar events)"); }

- (NSString *)navigationBarName 
{ return NSLocalizedStringFromTable(@"Upcoming Events", @"StandardUI", @"The long title for buttons and tabs related to committee meetings (or calendar events)"); }

+ (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"83-calendar-inv"]; }


////////////////////////////////////////

// Set this to non-nil whenever you want to automatically enable/disable the view controller based on network/host reachability
- (NSString *)reachabilityStatusKey {
	return @"openstatesConnectionStatus";
}

- (NSString *)apiFeatureFlag {
    return @"events";
}


- (void)loadView {
	[super runLoadView];
}

- (Class)dataSourceClass {
	return [CalendarDataSource class];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UILabel *typeWarning = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44.f)];
	typeWarning.text = NSLocalizedStringFromTable(@"Only committee meetings are available at this time", @"DataTableUI", @"Disclaimer for event types");
	typeWarning.font = [TexLegeTheme boldTen];
	typeWarning.textColor = [TexLegeTheme textLight];
	typeWarning.textAlignment = UITextAlignmentCenter;
	typeWarning.lineBreakMode = UILineBreakModeWordWrap;
	typeWarning.backgroundColor = self.tableView.backgroundColor;
	self.tableView.tableFooterView = typeWarning;
	[typeWarning release];
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
		
	if ([UtilityMethods isIPadDevice]) {
		if (self.navigationController)
			self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	}
}

#pragma -
#pragma UITableViewDelegate

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	
	if (![UtilityMethods isIPadDevice])
		[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
		
	id dataObject = [self.dataSource dataObjectForIndexPath:newIndexPath];

	[[SLFPersistenceManager sharedPersistence] setTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
	
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
