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
#import "StretchedTitleLabel.h"

@interface StatesViewController()
- (void)pushOrSendViewControllerWithState:(SLFState *)newState;
- (void)configureTableHeader;
@end

@implementation StatesViewController
@synthesize tableViewModel = __tableViewModel;
@synthesize stateMenuDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading...",@"");
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
    self.tableViewModel.resourcePath = [@"/metadata" appendQueryParams:queryParams];
    [self.tableViewModel setObjectMappingForClass:[SLFState class]]; 
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.autoRefreshRate = 360;
    self.tableViewModel.pullToRefreshEnabled = YES;
    self.tableViewModel.showsSectionIndexTitles = YES;
    self.tableViewModel.variableHeightRows = YES;
    self.tableViewModel.sectionNameKeyPath = @"stateInitial";

    SubtitleCellMapping *stateCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"stateID" toAttribute:@"detailTextLabel.text"];
        [cellMapping mapKeyPath:@"stateFlag" toAttribute:@"imageView.image"];
        cellMapping.rowHeight = 48;
        
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFState *state = object;
            SLFSaveSelectedState(state);
//          [[SLFRestKitManager sharedRestKit] preloadObjectsForState:state];
            [self pushOrSendViewControllerWithState:state];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFState class] toTableCellsWithMapping:stateCellMap];    

    [self.tableViewModel loadTable];    
    
    if (!PSIsIpad())
        [self configureTableHeader];
    
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

- (void)configureTableHeader {
    CGRect contentRect = CGRectMake(0, 0, self.view.width, 40);
    StretchedTitleLabel *stretchedTitle = CreateOpenStatesTitleLabelForFrame(contentRect);
    UIColor *background = [SLFAppearance cellBackgroundLightColor];
    stretchedTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    stretchedTitle.backgroundColor = background;
    self.tableView.top += 40;
    self.tableView.height -= 40;
    [self.view addSubview:stretchedTitle];
    [stretchedTitle release];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d States",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)dealloc {
    self.stateMenuDelegate = nil;
    self.tableViewModel = nil;
     [super dealloc];
}

- (void)pushOrSendViewControllerWithState:(SLFState *)state {
    NSParameterAssert(state != NULL);
    if (self.stateMenuDelegate) {
        [self.stateMenuDelegate reconfigureForState:state];
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        StateDetailViewController *vc = [[StateDetailViewController alloc] initWithState:state];
        [self stackOrPushViewController:vc];
        [vc release];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

@end
