//
//  StatesViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
#import "OpenStatesTitleView.h"
#import "InlineSubtitleCell.h"

@interface StatesViewController()
- (void)pushOrSendViewControllerWithState:(SLFState *)newState;
- (void)loadFromNetworkIfEmpty;
- (void)configureTableHeader;
@end

@implementation StatesViewController
@synthesize stateMenuDelegate;

- (id)init {
    self = [super initWithState:nil resourcePath:[SLFState resourcePathForAll] dataClass:[SLFState class]];
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
    self.stateMenuDelegate = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableHeader];
    [self loadFromNetworkIfEmpty];
    self.screenName = @"States Screen";
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.showsSectionIndexTitles = YES;
    self.tableController.sectionNameKeyPath = @"stateInitial";
    self.tableView.rowHeight = 48;
    __block __typeof__(self) bself = self;
    InlineSubtitleMapping *cellMapping = [InlineSubtitleMapping cellMapping];
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        if (!object || ![object isKindOfClass:[SLFState class]])
            return;
        SLFState *state = object;
        SLFSaveSelectedState(state);
            //[[SLFRestKitManager sharedRestKit] preloadObjectsForState:state];
        [bself pushOrSendViewControllerWithState:state];
    };
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:cellMapping];
    
    RKTableItem *tableItem = [RKTableItem tableItemWithText:NSLocalizedString(@"choose a state to get started.", @"")];
    tableItem.cellMapping = [StyledCellMapping styledMappingUsingBlock:^(StyledCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"text" toAttribute:@"textLabel.text"];
        cellMapping.isSelectableCell = NO;
        cellMapping.useAlternatingRowColors = YES;
        cellMapping.textColor = [SLFAppearance cellSecondaryTextColor];
        cellMapping.textFont = SLFItalicFont(14);
        cellMapping.style = UITableViewCellStyleDefault;
    }];
    [self.tableController addHeaderRowForItem:tableItem];
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    if (!self.tableController.isEmpty)
        self.title = NSLocalizedString(@"States", @"");
}

- (void)loadFromNetworkIfEmpty {
    @try {
        [self.tableController loadTableFromNetwork];
    }
    @catch (NSException *exception) {
        RKLogWarning(@"Exception while attempting to load list of available states from network (already in progress?) ... %@", exception);
    }
}

CGFloat const kTitleHeight = 30;

- (void)configureTableHeader {
    if (SLFIsIpad())
        return;
    CGRect contentRect = CGRectMake(15, 0, self.view.width-30, kTitleHeight);
    OpenStatesTitleView *stretchedTitle = [[OpenStatesTitleView alloc] initWithFrame:contentRect];
    stretchedTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationItem.titleView = stretchedTitle;
    [stretchedTitle release];
}

- (void)pushOrSendViewControllerWithState:(SLFState *)state {
    NSParameterAssert(state != NULL);
    if (self.stateMenuDelegate)
        [self.stateMenuDelegate stateMenuSelectionDidChangeWithState:state];
    else {
        NSString *path = [SLFActionPathNavigator navigationPathForController:[StateDetailViewController class] withResource:state];
        if (!IsEmpty(path)) {
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.imageView.image)
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

@end
