//
//  StateDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StateDetailViewController.h"
#import "LegislatorsViewController.h"
#import "CommitteesViewController.h"
#import "DistrictsViewController.h"
#import "EventsViewController.h"
#import "BillsMenuViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "UIImage+OverlayColor.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "SLFRestKitManager.h"
#ifdef DEBUG
#import "TestFlight.h"
#endif

#define MenuLegislators NSLocalizedString(@"Legislators", @"")
#define MenuCommittees NSLocalizedString(@"Committees", @"")
#define MenuDistricts NSLocalizedString(@"District Maps", @"")
#define MenuBills NSLocalizedString(@"Bills", @"")
#define MenuEvents NSLocalizedString(@"Events", @"")
#define MenuNews NSLocalizedString(@"News", @"")
#define MenuFeedback NSLocalizedString(@"Beta Feedback", @"")

@interface StateDetailViewController()
- (void)reconfigureForState:(SLFState *)state;
- (void)configureTableViewModel;
- (void)configureTableItems;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
@property (nonatomic,retain) UIImage *legislatorsIcon;
@property (nonatomic,retain) UIImage *committeesIcon;
@property (nonatomic,retain) UIImage *districtsIcon;
@property (nonatomic,retain) UIImage *eventsIcon;
@property (nonatomic,retain) UIImage *billsIcon;
@property (nonatomic,retain) UIImage *newsIcon;
@property (nonatomic,retain) UIImage *feedbackIcon;
@end

@implementation StateDetailViewController
@synthesize state = _state;
@synthesize tableViewModel = __tableViewModel;
@synthesize legislatorsIcon;
@synthesize committeesIcon;
@synthesize districtsIcon;
@synthesize eventsIcon;
@synthesize billsIcon;
@synthesize newsIcon;
@synthesize feedbackIcon;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        UIColor *iconColor = [SLFAppearance menuTextColor];
        self.legislatorsIcon = [[UIImage imageNamed:@"123-id-card"] imageWithOverlayColor:iconColor];
        self.committeesIcon = [[UIImage imageNamed:@"60-signpost"] imageWithOverlayColor:iconColor];                               
        self.districtsIcon = [[UIImage imageNamed:@"73-radar"] imageWithOverlayColor:iconColor];
        self.billsIcon = [[UIImage imageNamed:@"gavel"] imageWithOverlayColor:iconColor];
        self.eventsIcon = [[UIImage imageNamed:@"83-calendar"] imageWithOverlayColor:iconColor];
        self.newsIcon = [[UIImage imageNamed:@"166-newspaper"] imageWithOverlayColor:iconColor];
        self.feedbackIcon = [[UIImage imageNamed:@"110-bug"] imageWithOverlayColor:iconColor];
        [self stateMenuSelectionDidChangeWithState:newState];
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.state = nil;
    self.tableViewModel = nil;
    self.legislatorsIcon = nil;
    self.committeesIcon = nil;
    self.districtsIcon = nil;
    self.eventsIcon = nil;
    self.billsIcon = nil;
    self.newsIcon = nil;
    self.feedbackIcon = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableViewModel = nil;
    [super viewDidUnload];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableViewModel];
    if (self.state)
        self.title = self.state.name; 
}

- (void)stateMenuSelectionDidChangeWithState:(SLFState *)newState {
    self.state = newState;
    if (newState)
        [self loadDataFromNetworkWithID:newState.stateID];
}

+ (NSString *)actionPathForState:(SLFState *)state {
    if (!state)
        return nil;
    return RKMakePathWithObjectAddingEscapes(@"slfos://states/detail/:stateID", state, NO);
}

- (NSString *)actionPath {
    return [[self class] actionPathForState:self.state];
}

- (void)reconfigureForState:(SLFState *)state {
    if (state) {
        self.state = state;
        self.title = state.name;
    }
    [self configureTableItems];
}

- (void)configureTableViewModel {
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.pullToRefreshEnabled = NO;
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"stateID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/metadata/:stateID?apikey=:apikey", queryParams);
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(48)];
}

- (void)configureTableItems {
    NSMutableArray* tableItems = [[NSMutableArray alloc] initWithCapacity:15];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuLegislators detailText:nil image:self.legislatorsIcon]];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuCommittees detailText:nil image:self.committeesIcon]];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuDistricts detailText:nil image:self.districtsIcon]];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuBills detailText:nil image:self.billsIcon]];
    if (self.state && self.state.featureFlags && [self.state.featureFlags containsObject:@"events"])
        [tableItems addObject:[RKTableItem tableItemWithText:MenuEvents detailText:nil image:self.eventsIcon]];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuNews detailText:nil image:self.newsIcon]];
#ifdef DEBUG
    [tableItems addObject:[RKTableItem tableItemWithText:MenuFeedback detailText:nil image:self.feedbackIcon]];
#endif
    [self.tableViewModel loadTableItems:tableItems withMapping:[self menuCellMapping]];
    [tableItems release];
}

- (RKTableViewCellMapping *)menuCellMapping {
    SubtitleCellMapping *cellMap = [SubtitleCellMapping cellMapping];
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        RKTableItem* tableItem = (RKTableItem*) object;
        [self selectMenuItem:tableItem.text];
    };
    return cellMap;
}

- (void)selectMenuItem:(NSString *)menuItem {
	if (menuItem == NULL)
        return;
    UIViewController *vc = nil;
    if ([menuItem isEqualToString:MenuLegislators])
        vc = [[LegislatorsViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuCommittees])
        vc = [[CommitteesViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuDistricts])
        vc = [[DistrictsViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuEvents])
        vc = [[EventsViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuBills])
        vc = [[BillsMenuViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuNews]) {
        if (SLFIsReachableAddress(self.state.newsAddress)) {
            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:self.state.newsAddress];
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentModalViewController:webViewController animated:YES];	
            [webViewController release];
        }
    }
#ifdef DEBUG
    else if ([menuItem isEqualToString:MenuFeedback]) {
        [TestFlight openFeedbackView];
    }
#endif
    
    if (vc) {
        [self stackOrPushViewController:vc];
        [vc release];
    }
}
- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error",@"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    SLFState *state = nil;
    if (object && [object isKindOfClass:[SLFState class]])
        state = object;
    [self reconfigureForState:state];
}

@end
