    //
//  LinksMasterViewController.m
//  Created by Gregory Combs on 8/13/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LinksMasterViewController.h"
#import "UtilityMethods.h"

#import "SLFPersistenceManager.h"
#import "TableDataSourceProtocol.h"
#import "LinksDataSource.h"

#import "SVWebViewController.h"
#import "TexLegeTheme.h"
#import "TexLegeEmailComposer.h"
#import "TexLegeReachability.h"
#import "StatesListViewController.h"
#import "StateMetaLoader.h"

@interface LinksMasterViewController()

- (NSString *)stateLabelText;
- (IBAction)showStateList:(id)sender;
- (void)createStatePicker;
- (void)destroyStatePicker;
@end

@implementation LinksMasterViewController
@synthesize activeStateLabel;

- (Class)dataSourceClass {
	return [LinksDataSource class];
}

- (NSString *)nibName {
	return NSStringFromClass([self class]);
}


- (void)configure {
	[super configure];				
	self.selectObjectOnAppear = nil; // let's not go hitting up websites on startup (Resources) 
	
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.activeStateLabel = nil;
    
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
/*
- (void)loadView {	
	[super runLoadView];	
}
*/
- (void)viewDidLoad {
	[super viewDidLoad];	
    
	if (!self.selectObjectOnAppear && [UtilityMethods isIPadDevice])
		self.selectObjectOnAppear = [self firstDataObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(changeStateLabel:) 
                                                 name:kStateMetaNotifyStateLoaded 
                                               object:nil];
    
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.activeStateLabel = nil;
    self.toolbarItems = nil;
    
	[super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
    [self createStatePicker];

	//// ALL OF THE FOLLOWING MUST *NOT* RUN ON IPHONE (I.E. WHEN THERE'S NO SPLITVIEWCONTROLLER
	
	/*if ([UtilityMethods isIPadDevice] && self.selectObjectOnAppear == nil) {
		id detailObject = nil; //self.detailViewController ? [self.detailViewController valueForKey:@"link"] : nil;
		//if (!detailObject) {
			NSIndexPath *currentIndexPath = [self.tableView indexPathForSelectedRow];
			if (!currentIndexPath) {			
				NSUInteger ints[2] = {0,0};	// just pick the first one then
				currentIndexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
			}
			detailObject = [self.dataSource dataObjectForIndexPath:currentIndexPath];				
		//}
		self.selectObjectOnAppear = detailObject;
	}	*/
	
	if ([UtilityMethods isIPadDevice])
		[self.tableView reloadData]; 
	
	// END: IPAD ONLY
}

- (void) viewDidDisappear:(BOOL)animated {
    [self destroyStatePicker];
    [super viewDidDisappear:animated];
}

#pragma -
#pragma UITableViewDelegate

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)newIndexPath {
	[aTableView.delegate tableView:aTableView didSelectRowAtIndexPath:newIndexPath];
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	BOOL isSplitViewDetail = ([UtilityMethods isIPadDevice]) && (self.splitViewController != nil);
	
	if (!isSplitViewDetail)
		self.navigationController.toolbarHidden = YES;
	
	NSDictionary *link = [self.dataSource dataObjectForIndexPath:newIndexPath];
	if (link) {
		NSString *supportEmail = [[NSUserDefaults standardUserDefaults] stringForKey:kSupportEmailKey];
		NSString *url = [link valueForKey:@"url"];
		
        
		if ([url hasSuffix:supportEmail]) {
			NSString *appVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

			NSMutableString *body = [NSMutableString string];
			[body appendFormat:NSLocalizedStringFromTable(@"TexLege Version: %@\n", @"StandardUI", @"Text to be included in TexLege support emails."), appVer];
			[body appendFormat:NSLocalizedStringFromTable(@"iOS Version: %@\n", @"StandardUI", @"Text to be included in TexLege support emails."), [[UIDevice currentDevice] systemVersion]];
			[body appendFormat:NSLocalizedStringFromTable(@"iOS Device: %@\n", @"StandardUI", @"Text to be included in TexLege support emails."), [[UIDevice currentDevice] model]];
			[body appendString:NSLocalizedStringFromTable(@"\nDescription of Problem, Concern, or Question:\n", @"StandardUI", @"Text to be included in TexLege support emails.")];
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:supportEmail 
																			 subject:NSLocalizedStringFromTable(@"TexLege Support Question / Concern", @"StandardUI", @"Subject to be included in TexLege support emails.") 
																				body:body commander:self];
			return;
		}

		if ([url hasPrefix:@"http://realvideo"]) {
			NSURL *interAppURL = [NSURL URLWithString:url];
			if ([[UIApplication sharedApplication] canOpenURL:interAppURL]) {
				if ([TexLegeReachability canReachHostWithURL:interAppURL alert:YES])
					[[UIApplication sharedApplication] openURL:interAppURL];
				return;
			}
		}
		
		/*  TODO: do something smart with the Twitter API to drop results in a tableview or something.  (TTKit or whatever?)
		 if ([link.label isEqualToString:@"Legislator Twitter Feeds"]) {
		 
		 NSString *interAppTwitter = @"twitter://list?screen_name=grgcombs&slug=texas-politicians";
		 NSURL *interAppTwitterURL = [NSURL URLWithString:interAppTwitter];
		 if (![UtilityMethods isIPadDevice] && [[UIApplication sharedApplication] canOpenURL:interAppTwitterURL]) {
		 if ([TexLegeReachability canReachHostWithURL:interAppTwitterURL alert:YES])
		 [[UIApplication sharedApplication] openURL:interAppTwitterURL];
		 return;
		 }
		 }
		 */				
		
		// save off this item's selection to our persistence manager
		[[SLFPersistenceManager sharedPersistence] setTableSelection:newIndexPath forKey:NSStringFromClass([self class])];
		//self.selectObjectOnAppear= link;

		NSString *urlString = [[LinksDataSource actualURLForURLString:url] absoluteString];
		
		if (isSplitViewDetail == NO) {
			SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
			webViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:webViewController animated:YES];	
			[webViewController release];			
		}
		else if (self.detailViewController) {
			SVWebViewController *webViewController = self.detailViewController;
			webViewController.address = urlString;
		}
	}
}


#pragma mark -
#pragma mark State Legislature Picker

- (void)createStatePicker {
	[self.navigationController setToolbarHidden:NO animated:YES];
	self.navigationController.toolbar.tintColor = [TexLegeTheme accent];
    [self.navigationController.view setNeedsDisplay];
    [self.view setNeedsDisplay];

	
	UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)-60.f, 23.f)];
	stateLabel.font = [UIFont boldSystemFontOfSize:15];
	stateLabel.textColor = [TexLegeTheme backgroundLight];
	stateLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
	stateLabel.textAlignment = UITextAlignmentRight;
    stateLabel.lineBreakMode = UILineBreakModeTailTruncation;
	stateLabel.text = [self stateLabelText];
	stateLabel.opaque = NO;
	stateLabel.backgroundColor = [UIColor clearColor];
    stateLabel.adjustsFontSizeToFitWidth = YES;
    stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	self.activeStateLabel = stateLabel;
	
	UIBarButtonItem *labelButton = [[UIBarButtonItem alloc] initWithCustomView:stateLabel];
	UIBarButtonItem *iconButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"190-bank-inv"] 
																   style:UIBarButtonItemStylePlain 
																  target:self 
																  action:@selector(showStateList:)];
	
	[self setToolbarItems:[NSArray arrayWithObjects:labelButton, iconButton, nil] animated:YES];
	[stateLabel release];
	[labelButton release];
	[iconButton release];	
}

- (void)destroyStatePicker {
	[self setToolbarItems:nil animated:YES];
	self.activeStateLabel = nil;
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)changeStateLabel:(NSNotification *)notification {
    self.activeStateLabel.text = [self stateLabelText];
}

- (NSString *)stateLabelText {
    
    StateMetaLoader *meta = [StateMetaLoader sharedStateMeta];
    
	return [NSString stringWithFormat:@"%@: %@", 
            NSLocalizedStringFromTable(@"Active State",@"StandardUI",@"Current state legislature"), 
            [meta.selectedState uppercaseString]];
}


- (IBAction)showStateList:(id)sender {
    
    StatesListViewController *listVC = [[StatesListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.tabBarController presentModalViewController:listVC animated:YES];
    [listVC release];
}

@end
