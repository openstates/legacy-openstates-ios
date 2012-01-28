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
    self.stateMenuDelegate = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableHeader];
    [self loadFromNetworkIfEmpty];
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.showsSectionIndexTitles = YES;
    self.tableController.sectionNameKeyPath = @"stateInitial";
    self.tableView.rowHeight = 48;
    __block __typeof__(self) bself = self;
    SubtitleCellMapping *objCellMap = [SubtitleCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"name" toAttribute:@"textLabel.text"];
        [cellMapping mapKeyPath:@"stateIDForDisplay" toAttribute:@"detailTextLabel.text"];
        [cellMapping mapKeyPath:@"stateFlag" toAttribute:@"imageView.image"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            if (!object || ![object isKindOfClass:[SLFState class]])
                return;
            SLFState *state = object;
            SLFSaveSelectedState(state);
                //[[SLFRestKitManager sharedRestKit] preloadObjectsForState:state];
            [bself pushOrSendViewControllerWithState:state];
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];
    RKTableItem *tableItem = [RKTableItem tableItemWithText:NSLocalizedString(@"choose a state to get started.", @"")];
    tableItem.cellMapping = [RKTableViewCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"text" toAttribute:@"textLabel.text"];
        cellMapping.style = UITableViewCellStyleDefault;
        cellMapping.selectionStyle = UITableViewCellSelectionStyleNone;
        cellMapping.accessoryType = UITableViewCellAccessoryNone;
        cellMapping.reuseIdentifier = @"DONT_REUSE_ME!";
        cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            cell.textLabel.textColor = [SLFAppearance cellSecondaryTextColor];
            cell.textLabel.font = SLFItalicFont(14);
            SLFAlternateCellForIndexPath(cell, indexPath);
        };
    }];
    [self.tableController addHeaderRowForItem:tableItem];
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    [super tableControllerDidFinishFinalLoad:tableController];
    self.title = [NSString stringWithFormat:@"%d States", self.tableController.rowCount];
}

- (void)loadFromNetworkIfEmpty {
    NSInteger count = self.tableController.rowCount;
    if (count < 30) { // Sometimes we have 1 row, so 30 is an arbitrary but reasonable sanity check.
        @try {
            [self.tableController loadTableFromNetwork];
        }
        @catch (NSException *exception) {
            RKLogWarning(@"Exception while attempting to load list of available states from network (already in progress?) ... %@", exception);
        }
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
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.imageView.image)
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return cell;
}

@end
