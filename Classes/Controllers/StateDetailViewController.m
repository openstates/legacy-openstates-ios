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

#import "StatesViewController.h"
#import "StateDetailViewController.h"
#import "LegislatorsViewController.h"
#import "CommitteesViewController.h"
#import "DistrictsViewController.h"
#import "EventsViewController.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"

#define MenuLegislators NSLocalizedString(@"Legislators", @"")
#define MenuCommittees NSLocalizedString(@"Committees", @"")
#define MenuDistricts NSLocalizedString(@"District Maps", @"")
#define MenuBills NSLocalizedString(@"Bills", @"")
#define MenuEvents NSLocalizedString(@"Events", @"")

@interface StateDetailViewController()
- (void)selectMenuItem:(NSString *)menuItem;
- (void)configureTableItems;
- (void)loadDataFromNetworkWithID:(NSString *)resourceID;
@end

@implementation StateDetailViewController
@synthesize state;
@synthesize tableViewModel;

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (id)initWithState:(SLFState *)newState {
    self = [self init];
    if (self)
        [self reconfigureForState:newState];
    return self;
}

- (void)reconfigureForState:(SLFState *)newState {
    self.state = newState;
    if (newState)
        [self loadDataFromNetworkWithID:newState.stateID];
}

- (void)loadView {
    [super loadView];
    self.tableViewModel = [RKTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.pullToRefreshEnabled = NO;
    if (self.state)
        self.title = self.state.name; 
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.state = nil;
    self.tableViewModel = nil;
    [super dealloc];
}

- (void)selectMenuItem:(NSString *)menuItem {
	if (menuItem == NULL)
        return;

    if ([menuItem isEqualToString:MenuLegislators]) {
        LegislatorsViewController *vc = [[LegislatorsViewController alloc] initWithState:self.state];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else if ([menuItem isEqualToString:MenuCommittees]) {
        CommitteesViewController *vc = [[CommitteesViewController alloc] initWithState:self.state];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else if ([menuItem isEqualToString:MenuDistricts]) {
        DistrictsViewController *vc = [[DistrictsViewController alloc] initWithState:self.state];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else if ([menuItem isEqualToString:MenuEvents]) {
        EventsViewController *vc = [[EventsViewController alloc] initWithState:self.state];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
/*
    else if ([menuItem isEqualToString:MenuBills]) {
        BillsViewController *vc = [[BillsViewController alloc] initWithState:self.state];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
*/
}

- (void)loadDataFromNetworkWithID:(NSString *)resourceID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", resourceID, @"stateID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/metadata/:stateID?apikey=:apikey", queryParams);
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[SLFState class]];
    }];
}

- (void)configureTableItems {
    NSMutableArray* tableItems = [NSMutableArray arrayWithArray:[RKTableItem tableItemsFromStrings:MenuLegislators, MenuCommittees, MenuDistricts, /*MenuBills,*/ nil]];
    if (self.state && self.state.featureFlags && [self.state.featureFlags containsObject:@"events"])
        [tableItems addObject:[RKTableItem tableItemWithText:MenuEvents]];
    [self.tableViewModel loadTableItems:tableItems withMappingBlock:^(RKTableViewCellMapping* cellMapping) {
        cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            RKTableItem* tableItem = (RKTableItem*) object;
            [self selectMenuItem:tableItem.text];
        };
    }];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = @"Load Error";
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    self.state = object;
    if (self.state)
        self.title = self.state.name;
    if (![self isViewLoaded]) { // finished loading too soon?  Would this ever happen?
        [self performSelector:@selector(objectLoader:didLoadObject:) withObject:object afterDelay:2];
        return;
    }
    [self configureTableItems];
}

@end
