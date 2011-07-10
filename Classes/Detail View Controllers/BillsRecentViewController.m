//
//  BillsRecentViewController.m
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillsRecentViewController.h"
#import "OpenLegislativeAPIs.h"
#import "UtilityMethods.h"
#import "BillSearchDataSource.h"
#import "NSDate+Helper.h"
#import "StateMetaLoader.h"
#import "TexLegeTheme.h"

@implementation BillsRecentViewController

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		dataSource.useLoadingDataCell = YES;
	}
	return self;
}

- (void)dealloc {		
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = NSStringFromClass([self class]);
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];	
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
	if (IsEmpty(meta.selectedState))
		return;
	
	NSDate *daysAgo = [[NSDate date] dateByAddingDays:-5];
	if (!daysAgo) {
		// we had issues calculating last week's date, so just do it by hand
		daysAgo = [[[NSDate alloc] initWithTimeIntervalSinceNow:-(60*60*24*5)] autorelease];	
	}
	NSString *dateString = [daysAgo stringWithFormat:[NSDate dateFormatString]];
	
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 dateString, @"updated_since",
								 meta.selectedState, @"state",
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
	
	[self.dataSource startSearchWithQueryString:@"/bills" params:queryParams];
}

@end
