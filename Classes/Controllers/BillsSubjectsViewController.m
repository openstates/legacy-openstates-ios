//
//  BillsSubjectsViewController.m
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillsSubjectsViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "SLFAppearance.h"
#import "SLFRestKitManager.h"
#import "BillsViewController.h"
#import "BillSearchParameters.h"
#import "SLFBadgeCell.h"
#import "MTInfoPanel.h"
#import "SLFDrawingExtensions.h"

@interface BillsSubjectsViewController()
- (void)configureTableController;
- (void)configureStandaloneChamberScopeBar;
- (void)chamberScopeSelectedIndexDidChange:(UISegmentedControl *)scopeBar;
@end

@implementation BillsSubjectsViewController
@synthesize state;
@synthesize tableController = _tableController;

- (id)initWithState:(SLFState *)newState {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Subjects", @"");
        self.useTitleBar = SLFIsIpad();
        self.state = newState;
        [self reconfigureForState:newState];
    }
    return self;
}

- (void)dealloc {
	self.state = nil;
    self.tableController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SLFAppearance menuBackgroundColor];
    self.tableView.opaque = YES;
    [self configureStandaloneChamberScopeBar];
    [self configureTableController];
    if (self.state) {
        self.title = [NSString stringWithFormat:@"%@ %@", self.state.name, NSLocalizedString(@"Subjects",@"")];
        [self reconfigureForState:self.state];
    }
    self.screenName = @"Bills Search Screen";
}

- (void)reconfigureForState:(SLFState *)newState {
    if (!newState || !self.tableController)
        return;
    self.state = newState;
    NSInteger chamberScope = SLFSelectedScopeIndexForKey(NSStringFromClass([self class]));
    NSString *chamber = [SLFChamber chamberTypeForSearchScopeIndex:chamberScope];
    NSString *resourcePath = [BillSearchParameters pathForSubjectsWithState:newState chamber:chamber];
    [_tableController loadTableFromResourcePath:resourcePath usingBlock:^(RKObjectLoader* objectLoader) {
        objectLoader.URLRequest.timeoutInterval = 30;
        objectLoader.cacheTimeoutInterval = SLF_HOURS_TO_SECONDS(6);
        objectLoader.objectMapping = [BillsSubjectsEntry mapping];
    }];
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.state];
}

- (void)configureTableController {
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = YES;
    _tableController.imageForError = [UIImage imageNamed:@"error"];
    CGFloat panelWidth = SLFIsIpad() ? self.stackWidth : self.tableView.width;
    MTInfoPanel *offlinePanel = [MTInfoPanel staticPanelWithFrame:CGRectMake(0,0,panelWidth,60) type:MTInfoPanelTypeError title:NSLocalizedString(@"Offline", @"") subtitle:NSLocalizedString(@"The server is unavailable.",@"") image:nil];
    _tableController.imageForOffline = [UIImage imageFromView:offlinePanel];    
    MTInfoPanel *panel = [MTInfoPanel staticPanelWithFrame:CGRectMake(0,0,panelWidth,60) type:MTInfoPanelTypeActivity title:NSLocalizedString(@"Updating", @"") subtitle:NSLocalizedString(@"Downloading new data",@"") image:nil];
    _tableController.loadingView = panel;

    __block __typeof__(self) bself = self;
    StyledCellMapping *styledCellMap = [StyledCellMapping styledMappingForClass:[SLFBadgeCell class] usingBlock:^(StyledCellMapping *cellMapping){
        cellMapping.useAlternatingRowColors = YES;
        [cellMapping mapKeyPath:@"self" toAttribute:@"subjectEntry"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            if (!object || ![object isKindOfClass:[BillsSubjectsEntry class]])
                return;
            if ([cell respondsToSelector:@selector(isClickable)]) {
                BOOL clickable = [[cell valueForKey:@"isClickable"] boolValue];
                if (!clickable)
                    return;
            }
            BillsSubjectsEntry *subject = object;
            NSInteger chamberScope = SLFSelectedScopeIndexForKey(NSStringFromClass([bself class]));
            NSString *chamber = [SLFChamber chamberTypeForSearchScopeIndex:chamberScope];
            NSString *resourcePath = [BillSearchParameters pathForSubject:subject.name chamber:chamber];
            BillsViewController *vc = [[BillsViewController alloc] initWithState:bself.state resourcePath:resourcePath];
            if (IsEmpty(chamber))
                vc.title = [NSString stringWithFormat:@"%@ %@ Bills", bself.state.name, subject.name];
            else {
                NSString *chamberName = [SLFChamber chamberWithType:chamber forState:bself.state].shortName;
                vc.title = [NSString stringWithFormat:@"%@ %@ %@ Bills", bself.state.stateIDForDisplay, chamberName, subject.name];
            }
            [bself stackOrPushViewController:vc];
            [vc release];
        };
    }];
    [_tableController mapObjectsWithClass:[BillsSubjectsEntry class] toTableCellsWithMapping:styledCellMap];
}

- (void)configureStandaloneChamberScopeBar {
    NSArray *buttonTitles = [SLFChamber chamberSearchScopeTitlesWithState:state];
    if (IsEmpty(buttonTitles))
        return;
    UISegmentedControl *scopeBar = [[UISegmentedControl alloc] initWithItems:buttonTitles];
    scopeBar.selectedSegmentIndex = SLFSelectedScopeIndexForKey(NSStringFromClass([self class]));
    [scopeBar addTarget:self action:@selector(chamberScopeSelectedIndexDidChange:) forControlEvents:UIControlEventValueChanged];
    scopeBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

    CGFloat barInset = 0.0f;
    if ([[UIDevice currentDevice] systemMajorVersion] < 7) {
        scopeBar.segmentedControlStyle = 7; // magic number (it's cheating)
    } else {
        scopeBar.tintColor = [SLFAppearance cellSecondaryTextColor];
        barInset += 12.0f;
    }
    scopeBar.opaque = YES;
    CGFloat barOriginY = self.titleBarView.opticalHeight + barInset/2;
    CGFloat barHeight = scopeBar.height;
    CGFloat barWidth = self.tableView.bounds.size.width - (2*barInset);
    scopeBar.origin = CGPointMake(barInset,barOriginY);
    scopeBar.size = CGSizeMake(barWidth, barHeight);
    CGRect tableRect = self.tableView.frame;
    tableRect.size.height -= (scopeBar.height);
    self.tableView.frame = CGRectOffset(tableRect, 0, scopeBar.height + barInset);
    [self.view addSubview:scopeBar];
    [scopeBar release];
}

- (void)chamberScopeSelectedIndexDidChange:(UISegmentedControl *)scopeBar {
    if (!scopeBar || ![scopeBar isKindOfClass:[UISegmentedControl class]])
        return;
    NSInteger selectedScope = scopeBar.selectedSegmentIndex;
    SLFSaveSelectedScopeIndexForKey(selectedScope, NSStringFromClass([self class]));
    [self reconfigureForState:self.state];
}

- (void)resizeLoadingView {
    if (!self.tableController.loadingView)
        return;
    self.tableController.loadingView.width = self.tableView.width;
}

- (void)tableControllerDidStartLoad:(RKAbstractTableController *)tableController {
    [self resizeLoadingView];
}

- (void)tableControllerDidFinishLoad:(RKAbstractTableController *)tableController {
    // since we reload our table items, we can't use our usual finishLoading or risk an infinite loop.
    if (IsEmpty(tableController.sections))
        return;
    RKTableSection *section = [tableController sectionAtIndex:0];
    if (!section)
        return;
    NSArray *sortedObjects = [section.objects sortedArrayUsingDescriptors:[BillsSubjectsEntry sortDescriptors]];
    [_tableController loadObjects:sortedObjects];
    [_tableController.tableView reloadData];
}

@end
