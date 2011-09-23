//
//  StatesViewController.m
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
#import "SLFState.h"
#import "SLFRestKitManager.h"

@implementation StatesViewController
@synthesize tableViewModel = __tableViewModel;


- (void)loadView {
    [super loadView];
    self.title = @"Loading...";
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
    self.tableViewModel.resourcePath = [@"/metadata" appendQueryParams:queryParams];
    [self.tableViewModel setObjectMappingForClass:[SLFState class]]; 
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.autoRefreshRate = 360;
    self.tableViewModel.pullToRefreshEnabled = YES;
    
    RKTableViewCellMapping *stateCellMap = [RKTableViewCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        cellMapping.style = UITableViewCellStyleSubtitle;
        cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"stateID" toAttribute:@"detailTextLabel.text"];
        
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFState *state = object;
            [[SLFRestKitManager sharedRestKit] preloadObjectsForState:state];
            [[NSUserDefaults standardUserDefaults] setObject:state.stateID forKey:@"selectedState"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            StateDetailViewController *vc = [[StateDetailViewController alloc] initWithState:state];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFState class] toTableCellsWithMapping:stateCellMap];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableViewModel loadTable];    
    NSInteger count = [[self.tableViewModel.fetchedResultsController fetchedObjects] count];
    self.title = [NSString stringWithFormat:@"%d States",count];
    if (count == 0) {
        @try {
            [self.tableViewModel loadTableFromNetwork];
        }
        @catch (NSException *exception) {
            RKLogWarning(@"Exception while attempting to load list of available states from network (already in progress?) ... %@", exception);
        }
    }
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d States",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)tableViewModel:(RKAbstractTableViewModel*)tableViewModel didFailLoadWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error",@"");
    RKLogError(@"Error loading table from resource path: %@", self.tableViewModel.resourcePath);
}

- (void)dealloc {
    self.tableViewModel = nil;
     [super dealloc];
}

@end
