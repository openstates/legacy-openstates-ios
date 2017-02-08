//
//  BillsSubjectsViewController.m
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "BillsSubjectsViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "SLFAppearance.h"
#import "SLFRestKitManager.h"
#import "BillsViewController.h"
#import "BillSearchParameters.h"
#import "SLFBadgeCell.h"
#import "SLToastManager+OpenStates.h"
#import "SLFDrawingExtensions.h"

@interface BillsSubjectsViewController()

@property (nonatomic, strong) UISegmentedControl *scopeBar;


- (void)configureTableController;
- (void)configureStandaloneChamberScopeBar;
- (void)chamberScopeSelectedIndexDidChange:(UISegmentedControl *)scopeBar;
@end

@implementation BillsSubjectsViewController
@synthesize state;
@synthesize tableController = _tableController;
@synthesize scopeBar;

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

- (void)configureTableController
{
    self.tableController = [SLFImprovedRKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO; // Don't enable this initially. Wait til the initial load has been done.
    _tableController.imageForError = [UIImage imageNamed:@"error"];

    CGFloat panelWidth = SLFIsIpad() ? self.stackWidth : self.tableView.width;
    CGFloat overlayTop = CGRectGetHeight(self.scopeBar.frame);
    self.tableController.overlayFrame = CGRectMake(0, overlayTop, panelWidth, CGRectGetHeight(self.view.frame));
    CGRect toastRect = CGRectMake(0, 0, panelWidth, 60);
    SLToastView *toastView = nil;

    SLToast *offlineToast = [SLToast toastWithIdentifier:@"BillSubjects-Server-Offline"
                                                    type:SLToastTypeError
                                                   title:NSLocalizedString(@"Offline", nil)
                                                subtitle:NSLocalizedString(@"The server is unavailable.", nil)
                                                   image:nil duration:-1];

    toastView = [SLToastView toastViewWithFrame:toastRect toast:offlineToast];
    _tableController.imageForOffline = [UIImage imageFromView:toastView];

    SLToast *updatingToast = [SLToast toastWithIdentifier:@"BillSubjects-Updating"
                                                    type:SLToastTypeActivity
                                                   title:NSLocalizedString(@"Updating", nil)
                                                subtitle:NSLocalizedString(@"Downloading new data", nil)
                                                   image:nil duration:3];

    toastView = [SLToastView toastViewWithFrame:toastRect toast:updatingToast];
    _tableController.loadingView = toastView;

    __weak __typeof__(self) bself = self;
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
            if (!SLFTypeNonEmptyStringOrNil(chamber))
                vc.title = [NSString stringWithFormat:@"%@ %@ Bills", bself.state.name, subject.name];
            else {
                NSString *chamberName = [SLFChamber chamberWithType:chamber forState:bself.state].shortName;
                vc.title = [NSString stringWithFormat:@"%@ %@ %@ Bills", bself.state.stateIDForDisplay, chamberName, subject.name];
            }
            [bself.searchBar resignFirstResponder];
            [bself stackOrPushViewController:vc];
        };
    }];
    [_tableController mapObjectsWithClass:[BillsSubjectsEntry class] toTableCellsWithMapping:styledCellMap];
}

- (void)configureStandaloneChamberScopeBar {
    NSArray *buttonTitles = [SLFChamber chamberSearchScopeTitlesWithState:state];
    if (!SLFTypeNonEmptyArrayOrNil(buttonTitles))
        return;
    self.scopeBar = [[UISegmentedControl alloc] initWithItems:buttonTitles];
    self.scopeBar.selectedSegmentIndex = SLFSelectedScopeIndexForKey(NSStringFromClass([self class]));
    [self.scopeBar addTarget:self action:@selector(chamberScopeSelectedIndexDidChange:) forControlEvents:UIControlEventValueChanged];
    self.scopeBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

    CGFloat barInset = 0.0f;
    if ([[UIDevice currentDevice] systemMajorVersion] < 7) {
//        self.scopeBar.segmentedControlStyle = 7; // magic number (it's cheating)
    } else {
        self.scopeBar.tintColor = [SLFAppearance cellSecondaryTextColor];
        barInset += 12.0f;
    }
    self.scopeBar.opaque = YES;
    CGFloat barOriginY = self.titleBarView.opticalHeight + barInset/2;
    CGFloat barHeight = self.scopeBar.height;
    CGFloat barWidth = self.tableView.bounds.size.width - (2*barInset);
    self.scopeBar.origin = CGPointMake(barInset,barOriginY);
    self.scopeBar.size = CGSizeMake(barWidth, barHeight);
    CGRect tableRect = self.tableView.frame;
    tableRect.size.height -= (self.scopeBar.height);
    self.tableView.frame = CGRectOffset(tableRect, 0, self.scopeBar.height + barInset);
    [self.view addSubview:self.scopeBar];
}

- (void)chamberScopeSelectedIndexDidChange:(UISegmentedControl *)pScopeBar {
    if (!pScopeBar || ![pScopeBar isKindOfClass:[UISegmentedControl class]])
        return;
    NSInteger selectedScope = pScopeBar.selectedSegmentIndex;
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
    if (!SLFTypeNonEmptyArrayOrNil(tableController.sections))
        return;
    RKTableSection *section = [tableController sectionAtIndex:0];
    if (!section)
        return;
    NSArray *sortedObjects = [section.objects sortedArrayUsingDescriptors:[BillsSubjectsEntry sortDescriptors]];
    [_tableController loadObjects:sortedObjects];
    [_tableController.tableView reloadData];
    _tableController.pullToRefreshEnabled = YES;
}

@end
