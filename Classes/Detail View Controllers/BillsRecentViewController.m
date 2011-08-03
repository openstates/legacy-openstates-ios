//
//  BillsRecentViewController.m
//  Created by Gregory Combs on 3/14/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsRecentViewController.h"
#import "SLFDataModels.h"

#import "OpenLegislativeAPIs.h"
#import "UtilityMethods.h"
#import "BillSearchDataSource.h"
#import "NSDate+Helper.h"
#import "StateMetaLoader.h"
#import "TexLegeTheme.h"

@interface BillsRecentViewController()

- (void)runDataQuery:(id)sender;

@end


@implementation BillsRecentViewController

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
	}
	return self;
}

- (void)dealloc {		
	[[NSNotificationCenter defaultCenter] removeObserver:self];	

	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(stateChanged:) 
												 name:kStateMetaNotifyStateLoaded 
                                               object:nil];

	NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"TexLegeStrings" ofType:@"plist"];
	NSDictionary *textDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	NSString *myClass = NSStringFromClass([self class]);
	NSDictionary *menuItem = [[textDict objectForKey:@"BillMenuItems"] findWhereKeyPath:@"class" equals:myClass];
	
	if (menuItem)
		self.title = [menuItem objectForKey:@"title"];	
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];

	[self runDataQuery:nil];
}

- (void)stateChanged:(NSNotification *)notification {
    [self runDataQuery:notification];
}

- (void)runDataQuery:(id)sender {
	StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
	if (!meta.selectedState)
		return;
	
	NSDate *daysAgo = [[NSDate date] dateByAddingDays:-5];
	if (!daysAgo) {
		// we had issues calculating last week's date, so just do it by hand
		daysAgo = [[[NSDate alloc] initWithTimeIntervalSinceNow:-(60*60*24*5)] autorelease];	
	}
	NSString *dateString = [daysAgo stringWithFormat:[NSDate dateFormatString]];
	
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 dateString, @"updated_since",
								 meta.selectedState.abbreviation, @"state",
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
	
	[self.dataSource startSearchWithQueryString:@"/bills" params:queryParams];
	
}

@end
