//
//  BillsMenuViewController.m
//  Created by Gregory Combs on 11/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsMenuViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "UIImage+OverlayColor.h"
#import "SLFRestKitManager.h"
#import "BillsViewController.h"

#define MenuFavorites NSLocalizedString(@"Watch List", @"")
#define MenuSearch NSLocalizedString(@"Search Bills", @"")
#define MenuRecents NSLocalizedString(@"Recently Active Bills", @"")
#define MenuSubjects NSLocalizedString(@"Bills By Subject", @"")

@interface BillsMenuViewController()
- (void)configureTableItems;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
@property (nonatomic,retain) UIImage *searchIcon;
@property (nonatomic,retain) UIImage *favoritesIcon;
@property (nonatomic,retain) UIImage *recentsIcon;
@property (nonatomic,retain) UIImage *subjectsIcon;
@end

@implementation BillsMenuViewController
@synthesize state;
@synthesize tableViewModel;
@synthesize searchIcon;
@synthesize favoritesIcon;
@synthesize subjectsIcon;
@synthesize recentsIcon;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Bills", @"");
        UIColor *iconColor = [SLFAppearance menuTextColor];
        self.searchIcon = [[UIImage imageNamed:@"06-magnify"] imageWithOverlayColor:iconColor];
        self.favoritesIcon = [[UIImage imageNamed:@"28-star"] imageWithOverlayColor:iconColor];
        self.recentsIcon = [[UIImage imageNamed:@"11-clock"] imageWithOverlayColor:iconColor];                               
        self.subjectsIcon = [[UIImage imageNamed:@"191-collection"] imageWithOverlayColor:iconColor];
        [self reconfigureForState:newState];
    }
    return self;
}

- (void)reconfigureForState:(SLFState *)newState {
    self.state = newState;
    if (newState)
        [self loadDataFromNetworkWithID:newState.stateID];
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.state = nil;
    self.tableViewModel = nil;
    self.searchIcon = nil;
    self.favoritesIcon = nil;
    self.recentsIcon = nil;
    self.subjectsIcon = nil;
    [super dealloc];
}

- (void)configureTableViewModel {
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.pullToRefreshEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableViewModel];
    if (self.state)
        self.title = self.state.name; 
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"stateID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/metadata/:stateID?apikey=:apikey", queryParams);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[SLFState class]];
        loader.cacheTimeoutInterval = 24 * 60 * 60;
    }];
}

- (void)configureTableItems {
    NSMutableArray* tableItems = [[NSMutableArray alloc] initWithCapacity:15];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuSearch detailText:nil image:self.searchIcon]];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuFavorites detailText:nil image:self.favoritesIcon]];
    [tableItems addObject:[RKTableItem tableItemWithText:MenuRecents detailText:nil image:self.recentsIcon]];
    if (self.state && self.state.featureFlags && [self.state.featureFlags containsObject:@"subjects"])
	    [tableItems addObject:[RKTableItem tableItemWithText:MenuSubjects detailText:nil image:self.subjectsIcon]];
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
    if ([menuItem isEqualToString:MenuRecents])
        vc = [[BillsViewController alloc] initWithState:self.state];
        /*
    if ([menuItem isEqualToString:MenuLegislators])
        vc = [[LegislatorsViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuCommittees])
        vc = [[CommitteesViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuDistricts])
        vc = [[DistrictsViewController alloc] initWithState:self.state];
    else if ([menuItem isEqualToString:MenuEvents])
        vc = [[EventsViewController alloc] initWithState:self.state];
    }
//  else if ([menuItem isEqualToString:MenuBills])
//      vc = [[BillsViewController alloc] initWithState:self.state];
   */ 
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
    self.state = object;
    if (object)
        self.title = [NSString stringWithFormat:@"%@ %@", self.state.name, NSLocalizedString(@"Bills", @"")];
    [self configureTableItems];
}

@end
