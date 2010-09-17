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

@interface LegislatorContributionsViewController (Private)
@end

@implementation LegislatorContributionsViewController
@synthesize queryEntityID, contributionQueryType, dataSource;

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
	self.queryEntityID = nil;
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
	self.queryEntityID = nil;
	self.dataSource = nil;
	self.contributionQueryType = nil;
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Data Objects

- (void)setQueryEntityID:(NSString *)newObj withQueryType:(NSNumber *)newType {
	self.contributionQueryType = newType;
	self.dataSource.contributionQueryType = newType;
	
	self.queryEntityID = newObj;
}

- (void)setQueryEntityID:(NSString *)newObj {
	[self view];
	
	if (queryEntityID) [queryEntityID release], queryEntityID = nil;
	if (newObj) {		
		queryEntityID = [newObj retain];
		self.dataSource.queryEntityID = queryEntityID;
		self.navigationItem.title = [self.dataSource title];
	}
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TableCellDataObject *dataObject = [self.dataSource dataObjectForIndexPath:indexPath];
	
	if (dataObject && dataObject.isClickable) {
		LegislatorContributionsViewController *detail = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[detail setQueryEntityID:dataObject.entryValue withQueryType:[NSNumber numberWithInteger:dataObject.entryType]];		
		[self.navigationController pushViewController:detail animated:YES];
		[detail release];
		
	}
}



@end

