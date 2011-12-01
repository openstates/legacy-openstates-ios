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
- (void)loadFromNetworkIfEmpty;
- (void)configureTableHeader;
@end

@implementation StatesViewController
@synthesize stateMenuDelegate;

- (id)init {
    self = [super initWithState:nil resourcePath:[NSString stringWithFormat:@"/metadata?apikey=%@", SUNLIGHT_APIKEY] dataClass:[SLFState class]];
    if (self) {
        self.useTitleBar = NO;
    }
    return self;
}

- (void)dealloc {
    self.stateMenuDelegate = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.stateMenuDelegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!SLFIsIpad())
        [self configureTableHeader];
    [self loadFromNetworkIfEmpty];
    if (self.tableViewModel.rowCount && !self.title)
        self.title = [NSString stringWithFormat:@"%d States", self.tableViewModel.rowCount];
}

- (void)configureTableViewModel {
    [super configureTableViewModel];
    self.tableViewModel.showsSectionIndexTitles = YES;
    self.tableViewModel.sectionNameKeyPath = @"stateInitial";
    self.tableView.rowHeight = 48;
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"stateID" toAttribute:@"detailTextLabel.text"];
        [cellMapping mapKeyPath:@"stateFlag" toAttribute:@"imageView.image"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFState *state = object;
            SLFSaveSelectedState(state);
//          [[SLFRestKitManager sharedRestKit] preloadObjectsForState:state];
            [self pushOrSendViewControllerWithState:state];
        };
    }];
    [self.tableViewModel mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    [super tableViewModelDidFinishLoad:tableViewModel];
    if (!self.title)
        self.title = [NSString stringWithFormat:@"%d States", self.tableViewModel.rowCount];
}

- (void)loadFromNetworkIfEmpty {
    NSInteger count = self.tableViewModel.rowCount;
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

- (void)pushOrSendViewControllerWithState:(SLFState *)state {
    NSParameterAssert(state != NULL);
    if (self.stateMenuDelegate)
        [self.stateMenuDelegate stateMenuSelectionDidChangeWithState:state];
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
