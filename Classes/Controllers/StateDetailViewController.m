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
	self.state = nil;
    self.tableController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableController = nil;
    [super viewDidUnload];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableController];
    if (self.state)
        self.title = self.state.name; 
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.state];
}

- (void)stateMenuSelectionDidChangeWithState:(SLFState *)newState {
    self.state = newState;
    if (newState)
        [self loadDataFromNetworkWithID:newState.stateID];
}

- (void)reconfigureForState:(SLFState *)state {
    if (state) {
        self.state = state;
        self.title = state.name;
    }
    [self configureTableItems];
}

- (void)configureTableController {
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"stateID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/metadata/:stateID?apikey=:apikey", queryParams);
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
    SubtitleCellMapping *cellMap = [SubtitleCellMapping cellMapping];
    [cellMap mapKeyPath:@"highlightedImage" toAttribute:@"imageView.highlightedImage"];
    [cellMap addDefaultMappings];
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        RKTableItem* tableItem = (RKTableItem*) object;
        [self selectMenuItem:tableItem.text];
    };
    return cellMap;
}

- (void)configureTableItems {
    RKTableViewCellMapping *fixedMap = [self menuCellMapping];
    fixedMap.deselectsRowOnSelection = (SLFIsIpad() == NO);
    RKTableViewCellMapping *momentaryMap = [self menuCellMapping];
    momentaryMap.deselectsRowOnSelection = YES;
    NSMutableArray* tableItems = [[NSMutableArray alloc] initWithCapacity:15];
    [tableItems addObject:[self menuItemWithText:MenuLegislators imagePrefix:@"IndexCard" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuCommittees imagePrefix:@"Group" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuDistricts imagePrefix:@"Map" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuBills imagePrefix:@"Gavel" cellMapping:fixedMap]];
    if (self.state && self.state.featureFlags && [self.state.featureFlags containsObject:@"events"])
        [tableItems addObject:[self menuItemWithText:MenuEvents imagePrefix:@"Calendar" cellMapping:fixedMap]];
    [tableItems addObject:[self menuItemWithText:MenuNews imagePrefix:@"Paper" cellMapping:momentaryMap]];
#ifdef DEBUG
    [tableItems addObject:[self menuItemWithText:MenuFeedback imagePrefix:@"Bug" cellMapping:momentaryMap]];
#endif
    [_tableController loadTableItems:tableItems];
    [tableItems release];
}

- (void)selectMenuItem:(NSString *)menuItem {
	if (menuItem == NULL)
        return;
    Class controllerClass = nil;
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
    if (controllerClass) {
        NSString *path = [SLFActionPathNavigator navigationPathForController:controllerClass withResource:self.state];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:SLFIsIpad()];
        return;
    }
    if ([menuItem isEqualToString:MenuNews]) {
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
