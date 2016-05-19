//
//  StateDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StateDetailViewController.h"
#import "LegislatorsViewController.h"
#import "LegislatorsNoFetchViewController.h"
#import "CommitteesViewController.h"
#import "DistrictsViewController.h"
#import "EventsViewController.h"
#import "BillsMenuViewController.h"
#import "AssetsViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "UIImage+OverlayColor.h"
#import "SLFReachable.h"
#import "SLFRestKitManager.h"
#import "SLFEmailComposer.h"
@import SafariServices;

#define MenuMyRepresentatives NSLocalizedString(@"Who's My Rep?", @"")
#define MenuLegislators NSLocalizedString(@"Legislators", @"")
#define MenuCommittees NSLocalizedString(@"Committees", @"")
#define MenuDistricts NSLocalizedString(@"District Maps", @"")
#define MenuBills NSLocalizedString(@"Bills", @"")
#define MenuEvents NSLocalizedString(@"Events", @"")
#define MenuCapitolMaps NSLocalizedString(@"Capitol Maps", @"")
#define MenuNews NSLocalizedString(@"News", @"")
#define MenuFeedback NSLocalizedString(@"Feedback", @"")

@interface StateDetailViewController()
- (void)reconfigureForState:(SLFState *)state;
- (void)configureTableController;
- (void)configureTableItems;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
- (RKTableItem *)menuItemWithText:(NSString *)text imagePrefix:(NSString *)imagePrefix cellMapping:(RKTableViewCellMapping *)cellMap;
@end

@implementation StateDetailViewController
@synthesize state = _state;
@synthesize tableController = _tableController;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        [self stateMenuSelectionDidChangeWithState:newState];
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableController = nil;
    [super viewDidUnload];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableController];
    if (self.state) {
        self.title = self.state.name;
    }
    self.screenName = [NSString stringWithFormat:@"%@ State Screen", self.title];
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.state];
}

- (void)stateMenuSelectionDidChangeWithState:(SLFState *)newState {
    if (!newState)
        return;
    self.state = newState;
    [self loadDataFromNetworkWithID:newState.stateID];
}

- (void)reconfigureForState:(SLFState *)state {
    if (state) {
        self.state = state;
        self.title = state.name;
    }
    [self configureTableItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.state)
        self.title = self.state.name;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.state)
        self.title = self.state.stateIDForDisplay;
}

- (void)configureTableController {
    self.tableController = [SLFImprovedRKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSString *resourcePath = [SLFState resourcePathForStateID:resourceID];
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(48)];
}

- (RKTableItem *)menuItemWithText:(NSString *)text imagePrefix:(NSString *)imagePrefix cellMapping:(RKTableViewCellMapping *)cellMap {
    NSParameterAssert(text != NULL && imagePrefix != NULL);
    NSString *normalName = [imagePrefix stringByAppendingString:@"-Off"];
    NSString *highlightedName = [imagePrefix stringByAppendingString:@"-On"];
    RKTableItem *item = [RKTableItem tableItem];
    [item setText:text];
    [item setImage:[UIImage imageNamed:normalName]];
    [item setValue:[UIImage imageNamed:highlightedName] forKey:@"highlightedImage"]; // key value magic.
    item.cellMapping = cellMap;
    return item;
}

- (RKTableViewCellMapping *)menuCellMapping {
    StyledCellMapping *cellMap = [StyledCellMapping subtitleMapping];
    cellMap.useAlternatingRowColors = YES;
    [cellMap mapKeyPath:@"highlightedImage" toAttribute:@"imageView.highlightedImage"];
    [cellMap addDefaultMappings];
    __weak __typeof__(self) wSelf = self;
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        RKTableItem* tableItem = (RKTableItem*) object;
        [wSelf selectMenuItem:tableItem.text];
    };
    return cellMap;
}

- (void)configureTableItems {
    NSString *fixedReuseId = @"fixedMenuItemCell";
    RKTableViewCellMapping *fixedMap = [self menuCellMapping];
    fixedMap.deselectsRowOnSelection = (SLFIsIpad() == NO);
    fixedMap.reuseIdentifier = fixedReuseId;

    NSString *momentaryReuseId = @"momentaryMenuItemCell";
    RKTableViewCellMapping *momentaryMap = [self menuCellMapping];
    momentaryMap.deselectsRowOnSelection = YES;
    momentaryMap.reuseIdentifier = momentaryReuseId;

    NSMutableArray* tableItems = [[NSMutableArray alloc] initWithCapacity:15];
    [tableItems addObject:[self menuItemWithText:MenuMyRepresentatives imagePrefix:@"Locate" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuLegislators imagePrefix:@"IndexCard" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuCommittees imagePrefix:@"Group" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuDistricts imagePrefix:@"Map" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuBills imagePrefix:@"Gavel" cellMapping:fixedMap]];
    if (self.state && self.state.featureFlags && [self.state.featureFlags containsObject:@"events"])
        [tableItems addObject:[self menuItemWithText:MenuEvents imagePrefix:@"Calendar" cellMapping:fixedMap]];
    if (SLFTypeNonEmptySetOrNil(self.state.capitolMaps))
        [tableItems addObject:[self menuItemWithText:MenuCapitolMaps imagePrefix:@"Bank" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuNews imagePrefix:@"Paper" cellMapping:momentaryMap]];
    [tableItems addObject:[self menuItemWithText:MenuFeedback imagePrefix:@"Comment" cellMapping:momentaryMap]];

    @try {
        [self.tableView registerClass:fixedMap.cellClass forCellReuseIdentifier:fixedReuseId];
        [self.tableView registerClass:momentaryMap.cellClass forCellReuseIdentifier:momentaryReuseId];
        self.tableController.hasRegisteredCells = YES;
    }
    @catch (NSException *exception) {
    }
    [_tableController loadTableItems:tableItems];
    [_tableController.tableView reloadData];
    [_tableController.tableView setNeedsDisplay];
}

- (void)selectMenuItem:(NSString *)menuItem {
    if (menuItem == NULL)
        return;
    Class controllerClass = nil;
    id resource = self.state;
    if ([menuItem isEqualToString:MenuLegislators])
        controllerClass = [LegislatorsViewController class];
    else if ([menuItem isEqualToString:MenuCommittees])
        controllerClass = [CommitteesViewController class];
    else if ([menuItem isEqualToString:MenuDistricts])
        controllerClass = [DistrictsViewController class];
    else if ([menuItem isEqualToString:MenuEvents])
        controllerClass = [EventsViewController class];
    else if ([menuItem isEqualToString:MenuBills])
        controllerClass = [BillsMenuViewController class];
    else if ([menuItem isEqualToString:MenuCapitolMaps] && SLFTypeNonEmptySetOrNil(self.state.capitolMaps))
        controllerClass = [AssetsViewController class];
    else if ([menuItem isEqualToString:MenuMyRepresentatives])
        controllerClass = [LegislatorsNoFetchViewController class];
    if (controllerClass) {
        NSString *path = [SLFActionPathNavigator navigationPathForController:controllerClass withResource:resource];
        if (SLFTypeNonEmptyStringOrNil(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:SLFIsIpad()];
        return;
    }
    
    if ([menuItem isEqualToString:MenuNews]) {
        NSURL *URL = [NSURL URLWithString:self.state.newsAddress];
        if (!URL.scheme || ![@[@"https",@"http"] containsObject:URL.scheme])
            return;

        SLFReachabilityCompletionHandler completion = ^(NSURL *url, BOOL isReachable){
            if (!isReachable)
                return;

            SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:NO];
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:webViewController animated:YES completion:nil];
        };
        SLFIsReachableAddressAsync(URL,completion);
    }
    else if ([menuItem isEqualToString:MenuFeedback]) {
        [[SLFEmailComposer sharedComposer] presentAppSupportComposerFromParent:self];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error",@"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    if (!object || ![object isKindOfClass:[SLFState class]])
        return;
    SLFState *state = object;
    [self reconfigureForState:state];
}

@end
