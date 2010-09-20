//
//  LegislatorContributionsViewController.m
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LegislatorContributionsViewController.h"
#import "LegislatorContributionsDataSource.h"
#import "TableCellDataObject.h"
#import "UtilityMethods.h"
#import "LocalyticsSession.h"

@interface LegislatorContributionsViewController (Private)
@end

@implementation LegislatorContributionsViewController
@synthesize dataSource;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		if (!self.dataSource)
			self.dataSource = [[[LegislatorContributionsDataSource alloc] init] autorelease];
    }
    return self;
}


- (IBAction)contributionDataChanged:(id)sender {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	[self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	if (!self.dataSource)
		self.dataSource = [[[LegislatorContributionsDataSource alloc] init] autorelease];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contributionDataChanged:) name:kContributionsDataChangeNotificationKey object:self.dataSource];
	self.tableView.dataSource = self.dataSource;
}


- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kContributionsDataChangeNotificationKey object:self.dataSource];	
	self.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // Relinquish ownership any cached data, images, etc that aren't in use.
	// don't release our tableEntries array merely on low memory, since we'll be using it!
}


- (void)dealloc {
	self.dataSource = nil;
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Data Objects

- (void)setQueryEntityID:(NSString *)newObj type:(NSNumber *)newType cycle:(NSString *)newCycle {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *typeString = @"";
	switch ([newType integerValue]) {
		case kContributionQueryDonor:
			typeString = @"DonorSummaryQuery";
			break;
		case kContributionQueryRecipient:
			typeString = @"RecipientSummaryQuery";
			break;
		case kContributionQueryTop10Donors:
			typeString = @"Top10DonorsQuery";
			break;
		case kContributionQueryTop10Recipients:
			typeString = @"Top10RecipientsQuery";
			break;
		case kContributionQueryEntitySearch:
			typeString = @"EntitySearchQuery";
			break;
		default:
			break;
	}
	NSDictionary *logDict = [[NSDictionary alloc] initWithObjectsAndKeys:typeString, @"queryType", nil];
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"CONTRIBUTIONS_QUERY" attributes:logDict];
	[logDict release];

	[self.dataSource initiateQueryWithQueryID:newObj type:newType cycle:newCycle];
	self.navigationItem.title = [self.dataSource title];

}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TableCellDataObject *dataObject = [self.dataSource dataObjectForIndexPath:indexPath];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (dataObject && dataObject.isClickable) {
		if (!dataObject.entryValue || ![dataObject.entryValue length]) {
			NSString *queryName = @"";
			if (dataObject.title)
				queryName = dataObject.title;
			
			NSDictionary *logDict = [[NSDictionary alloc] initWithObjectsAndKeys:queryName, @"queryName", nil];
			[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"CONTRIBUTION_QUERY_ERROR" attributes:logDict];
			[logDict release];
			
			UIAlertView *dataAlert = [[[UIAlertView alloc] initWithTitle:@"Incomplete Records" 
																 message:@"The campaign finance data provider has incomplete information for this request.  You may visit followthemoney.org to perform a manual search." 
																delegate:self 
													   cancelButtonTitle:@"Cancel" 
													   otherButtonTitles:@"Open Website", nil] autorelease];
			if (dataAlert)
				[dataAlert show];
			
			return;
		}
		
		
		LegislatorContributionsViewController *detail = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];

		[detail setQueryEntityID:dataObject.entryValue type:dataObject.action cycle:dataObject.parameter];		
		[self.navigationController pushViewController:detail animated:YES];
		[detail release];
		
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView firstOtherButtonIndex]) {
		NSURL *url = [NSURL URLWithString:@"http://www.followthemoney.org"];
		[UtilityMethods openURLWithTrepidation:url];
	}
}


@end

