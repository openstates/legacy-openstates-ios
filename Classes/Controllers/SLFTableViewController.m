//
//  SLFTableViewController.m
//  Created by Greg Combs on 9/26/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"
#import "SLFAppearance.h"
#import "GradientBackgroundView.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "SLFDataModels.h"
#import "SLFActionPathRegistry.h"

@implementation SLFTableViewController
@synthesize useGradientBackground;
@synthesize useTitleBar;
@synthesize titleBarView = _titleBarView;
@synthesize onSavePersistentActionPath = _onSavePersistentActionPath;
@synthesize searchBar = _searchBar;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.stackWidth = 450;
        self.useGradientBackground = (style == UITableViewStyleGrouped);
        self.useTitleBar = NO;
    }
    return self;
}

- (void)dealloc {
    self.titleBarView = nil;
    self.onSavePersistentActionPath = nil;
    self.searchBar = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.titleBarView = nil;
    self.searchBar = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *background = [SLFAppearance tableBackgroundLightColor];
    self.tableView.backgroundColor = background;
    if (self.tableView.style == UITableViewStylePlain)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (self.useTitleBar) {
        _titleBarView = [[TitleBarView alloc] initWithFrame:self.view.bounds title:self.title];
        CGRect tableRect = self.tableView.frame;
        tableRect.size.height -= _titleBarView.opticalHeight;
        self.tableView.frame = CGRectOffset(tableRect, 0, _titleBarView.opticalHeight);
        if (!SLFIsIOS5OrGreater()) {
            UIColor *gradientTop = SLFColorWithRGBShift([SLFAppearance menuBackgroundColor], +20);
            UIColor *gradientBottom = SLFColorWithRGBShift([SLFAppearance menuBackgroundColor], -20);
            [_titleBarView setGradientTopColor:gradientTop];
            [_titleBarView setGradientBottomColor:gradientBottom];
            _titleBarView.titleFont = SLFTitleFont(14);
            _titleBarView.titleColor = [SLFAppearance navBarTextColor];
            [_titleBarView setStrokeTopColor:gradientTop];
        }
        [self.view addSubview:_titleBarView];
    }
    if (self.useGradientBackground) {
        GradientBackgroundView *gradient = [[GradientBackgroundView alloc] initWithFrame:self.tableView.bounds];
        gradient.backgroundColor = [SLFAppearance tableBackgroundLightColor];
        self.tableView.backgroundView = gradient;
        [gradient release];
    }
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:nil];
}

+ (NSString *)actionPathForObject:(id)object {
    NSString *pattern = [SLFActionPathRegistry patternForClass:[self class]];
    if (!pattern)
        return nil;
    if (!object)
        return pattern;
    return RKMakePathWithObjectAddingEscapes(pattern, object, NO);
}

- (void)setOnSavePersistentActionPath:(SLFPersistentActionsSaveBlock)onSavePersistentActionPath {
    if (_onSavePersistentActionPath) {
        Block_release(_onSavePersistentActionPath);
        _onSavePersistentActionPath = nil;
    }
    _onSavePersistentActionPath = Block_copy(onSavePersistentActionPath);
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if (self.useTitleBar && self.isViewLoaded)
        self.titleBarView.title = title;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)tableController:(RKAbstractTableController*)tableController willLoadTableWithObjectLoader:(RKObjectLoader *)objectLoader {
    objectLoader.URLRequest.timeoutInterval = 30; // something reasonable;
}

- (void)tableController:(RKAbstractTableController*)tableController didFailLoadWithError:(NSError*)error {
    self.onSavePersistentActionPath = nil;
    self.title = NSLocalizedString(@"Server Error",@"");
    RKLogError(@"Error loading table: %@", error);
    if ([tableController respondsToSelector:@selector(resourcePath)])
        RKLogError(@"-------- from resource path: %@", [tableController performSelector:@selector(resourcePath)]);
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    RKLogTrace(@"%@: Table controller finished loading.", NSStringFromClass([self class]));
    if (self.isViewLoaded)
        [self.tableView reloadData];
    if (self.onSavePersistentActionPath) {
        self.onSavePersistentActionPath(self.actionPath);
        self.onSavePersistentActionPath = nil;
    }
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    if (!SLFIsIpad())
        [self.navigationController pushViewController:viewController animated:YES];
    else
        [self.stackController pushViewController:viewController fromViewController:self animated:YES];
}

- (void)popToThisViewController {
    if (!SLFIsIpad())
        [SLFAppDelegateNav popToViewController:self animated:YES];
    else
        [SLFAppDelegateStack popToViewController:self animated:YES];
}

- (RKTableItem *)webPageItemWithTitle:(NSString *)itemTitle subtitle:(NSString *)itemSubtitle url:(NSString *)url {
    NSParameterAssert(!IsEmpty(url));
    BOOL useAlternatingRowColors = NO;
    if (self.isViewLoaded)
        useAlternatingRowColors =  (self.tableView.style == UITableViewStylePlain); 
    __block __typeof__(self) bself = self;
    StyledCellMapping *cellMapping = [StyledCellMapping cellMapping];
    cellMapping.style = UITableViewCellStyleSubtitle;
    cellMapping.useAlternatingRowColors = useAlternatingRowColors;
    cellMapping.onSelectCell = ^(void) {
        if (SLFIsReachableAddress(url)) {
            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            [bself presentViewController:webViewController animated:YES completion:NULL];
            [webViewController release];
        }
    };
    RKTableItem *webItem = [RKTableItem tableItemWithCellMapping:cellMapping];
    webItem.text = itemTitle;
    webItem.detailText = itemSubtitle;
    webItem.URL = url;
    return webItem;
}

#pragma mark - Search Bar Scope

- (void)configureSearchBarWithPlaceholder:(NSString *)placeholder withConfigurationBlock:(SearchBarConfigurationBlock)block {
    CGFloat tableWidth = self.tableView.bounds.size.width;
    CGRect searchRect = CGRectMake(0, self.titleBarView.opticalHeight, tableWidth, 44);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchRect];
    searchBar.delegate = self;
    searchBar.placeholder = placeholder;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    if (!SLFIsIOS5OrGreater())
        searchBar.tintColor = [SLFAppearance cellSecondaryTextColor];
    if (block)
        block(searchBar);
    [searchBar sizeToFit];
    searchBar.width = tableWidth;
    CGRect tableRect = self.tableView.frame;
    tableRect.size.height -= searchBar.height;
    self.tableView.frame = CGRectOffset(tableRect, 0, searchBar.height);
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    [searchBar release];
}

- (void)configureChamberScopeTitlesForSearchBar:(UISearchBar *)searchBar withState:(SLFState *)state {
    NSParameterAssert(searchBar != NULL);
    NSArray *buttonTitles = [SLFChamber chamberSearchScopeTitlesWithState:state];
    if (IsEmpty(buttonTitles))
        return;
    searchBar.showsScopeBar = YES;
    searchBar.scopeButtonTitles = buttonTitles;
    searchBar.selectedScopeButtonIndex = SLFSelectedScopeIndexForKey(NSStringFromClass([self class]));
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    SLFSaveSelectedScopeIndexForKey(selectedScope, NSStringFromClass([self class]));
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (IsEmpty(searchBar.text)) {
        searchBar.showsCancelButton = NO;
        [searchBar resignFirstResponder];
        return;
    }
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

@end
