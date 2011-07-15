//
//  LegislatorContributionsViewController.m
//  Created by Gregory Combs on 9/15/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorContributionsViewController.h"
#import "LegislatorContributionsDataSource.h"
#import "TableCellDataObject.h"
#import "UtilityMethods.h"
#import "LocalyticsSession.h"
#import "TexLegeTheme.h"
#import "SLFAlertView.h"

@interface LegislatorContributionsViewController (Private)
@end

@implementation LegislatorContributionsViewController
@synthesize dataSource;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
	
    if ((self = [super initWithStyle:style])) {
		
		dataSource = [[LegislatorContributionsDataSource alloc] init];
    }
    return self;
}


- (IBAction)contributionDataChanged:(id)sender {
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (!dataSource)
		dataSource = [[LegislatorContributionsDataSource alloc] init];

	self.tableView.dataSource = dataSource;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contributionDataChanged:) name:kContributionsDataNotifyLoaded object:dataSource];
	
	UILabel *nimsp = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 66)] autorelease];
	nimsp.backgroundColor = [UIColor clearColor];
	nimsp.font = [TexLegeTheme boldFourteen];
	nimsp.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	nimsp.textAlignment = UITextAlignmentCenter;
	nimsp.textColor = [TexLegeTheme navbar];
	nimsp.lineBreakMode = UILineBreakModeWordWrap;
	nimsp.numberOfLines = 3;
	nimsp.text = NSLocalizedStringFromTable(@"Data generously provided by the National Institute on Money in State Politics.", @"DataTableUI", @"Attribution for NIMSP");
	self.tableView.tableFooterView = nimsp;
}


- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kContributionsDataNotifyLoaded object:self.dataSource];	
	self.dataSource = nil;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kContributionsDataNotifyLoaded object:self.dataSource];	

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

	[self.dataSource initiateQueryWithQueryID:newObj 
										 type:newType 
										cycle:newCycle];
	
	self.navigationItem.title = [dataSource title];

}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	TableCellDataObject *dataObject = [self.dataSource dataObjectForIndexPath:indexPath];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (dataObject && dataObject.isClickable) {
		
		if (IsEmpty(dataObject.entryValue)) {
			
			NSString *queryName = @"";
			if (dataObject.title)
				queryName = dataObject.title;
			
			NSDictionary *logDict = [[NSDictionary alloc] initWithObjectsAndKeys:queryName, @"queryName", nil];
			[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"CONTRIBUTION_QUERY_ERROR" attributes:logDict];
			[logDict release];
			
			[SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Incomplete Records", @"AppAlerts", @"Title for alert.") 
								message:NSLocalizedStringFromTable(@"The campaign finance data provider has incomplete information for this request.  You may visit followthemoney.org to perform a manual search.", @"AppAlerts", @"") 
							cancelTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button title cancelling some action") 
							cancelBlock:^(void) {
								
							}
							 otherTitle:NSLocalizedStringFromTable(@"Open Website", @"StandardUI", @"Button title")
							 otherBlock:^(void) {
								 NSURL *url = [NSURL URLWithString:[UtilityMethods texLegeStringWithKeyPath:@"ExternalURLs.nimspWeb"]];
								 [UtilityMethods openURLWithTrepidation:url];
							 }];
						
			return;
		}
		
		
		LegislatorContributionsViewController *detail = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];

		[detail setQueryEntityID:dataObject.entryValue 
							type:dataObject.action 
						   cycle:dataObject.parameter];		
		
		[self.navigationController pushViewController:detail animated:YES];
		
		[detail release];
		
	}
}

@end

