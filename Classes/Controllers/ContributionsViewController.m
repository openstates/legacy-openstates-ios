//
//  ContributionsViewController.m
//  Created by Gregory Combs on 9/15/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "ContributionsViewController.h"
#import "ContributionsDataSource.h"
#import "TableCellDataObject.h"
#import "SLFTheme.h"
#import "SLFAlertView.h"
#import "GradientBackgroundView.h"
#import "TableSectionHeaderView.h"
#import "GenericDetailHeader.h"
#import "TitleBarView.h"

@interface ContributionsViewController()
@property (nonatomic,retain) TitleBarView *titleBarView;
@end

@implementation ContributionsViewController
@synthesize dataSource;
@synthesize titleBarView = _titleBarView;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        dataSource = [[ContributionsDataSource alloc] init];
        self.stackWidth = 380;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    self.dataSource = nil;
    self.titleBarView = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.titleBarView = nil;
    self.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
#if 0 // not sure I like this
    if (SLFIsIpad()) {
        self.titleBarView = nil;
        _titleBarView = [[TitleBarView alloc] initWithFrame:self.view.bounds title:self.title];
        CGRect tableRect = self.tableView.frame;
        tableRect.size.height -= _titleBarView.opticalHeight;
        self.tableView.frame = CGRectOffset(tableRect, 0, _titleBarView.opticalHeight);
        [self.view addSubview:_titleBarView];
    }
#endif
    if (!dataSource)
        dataSource = [[ContributionsDataSource alloc] init];
    self.tableView.dataSource = dataSource;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDataChanged:) name:kContributionsDataNotifyLoaded object:dataSource];
    
    UILabel *nimsp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.size.width, 66)];
    nimsp.backgroundColor = [UIColor clearColor];
    nimsp.font = SLFFont(14);
    nimsp.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    nimsp.textAlignment = UITextAlignmentCenter;
    nimsp.textColor = [SLFAppearance cellTextColor];
    nimsp.lineBreakMode = UILineBreakModeWordWrap;
    nimsp.numberOfLines = 3;
    nimsp.text = NSLocalizedString(@"Data generously provided by the National Institute on Money in State Politics.", @"");
    self.tableView.tableFooterView = nimsp;
    [nimsp release];
    
    GradientBackgroundView *gradient = [[GradientBackgroundView alloc] initWithFrame:self.tableView.bounds];
    [gradient loadLayerAndGradientColors];
    self.tableView.backgroundView = gradient;
    [gradient release];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if (self.titleBarView && self.isViewLoaded)
        _titleBarView.title = title;
}

- (void)updateTableHeader {
    NSDictionary *headerData = self.dataSource.tableHeaderData;
    if (IsEmpty(headerData)) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,10)];
        headerView.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = headerView;
        [headerView release];
        return;
    }
    NSString *title = [headerData valueForKey:@"title"];
    NSString *subtitle = [headerData valueForKey:@"subtitle"];
    NSString *detail = [headerData valueForKey:@"detail"];
    
    CGSize boxSize = CGSizeMake(self.tableView.width, 160);
    GenericDetailHeader *detailBox = [[GenericDetailHeader alloc] initWithFrame:CGRectMake(0,10,boxSize.width,boxSize.height-10)];
    detailBox.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    detailBox.defaultSize = boxSize;
    detailBox.title = title;
    detailBox.subtitle = subtitle;
    detailBox.detail = detail;
    [detailBox configure];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,detailBox.width,detailBox.height+20)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:detailBox];
    self.tableView.tableHeaderView = headerView;
    [detailBox release];
    [headerView release];
}

- (void)tableDataChanged:(NSNotification*)notification {
    [self updateTableHeader];
    [self.tableView reloadData];
    self.title = self.dataSource.title;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Data Objects

- (void)setQueryEntityID:(NSString *)newObj type:(NSNumber *)newType cycle:(NSString *)newCycle {
    [self.dataSource initiateQueryWithQueryID:newObj type:newType cycle:newCycle];
    self.navigationItem.title = [dataSource title];
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return TableSectionHeaderViewDefaultHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > [tableView numberOfSections])
        return nil;
    NSString *headerTitle = [self.dataSource tableView:tableView titleForHeaderInSection:section];
    if (IsEmpty(headerTitle))
        return nil;
    return [[[TableSectionHeaderView alloc] initWithTitle:headerTitle width:tableView.frame.size.width] autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableCellDataObject *dataObject = [self.dataSource dataObjectForIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!dataObject || !dataObject.isClickable)
        return;
    if (IsEmpty(dataObject.entryValue)) {
        [SLFAlertView showWithTitle:NSLocalizedString(@"Incomplete Records", @"") 
                            message:NSLocalizedString(@"The campaign finance data provider has incomplete information for this request.  You may choose to visit followthemoney.org to perform a manual search.", @"") 
                        cancelTitle:NSLocalizedString(@"Cancel", @"") 
                        cancelBlock:^(void) {}
                         otherTitle:NSLocalizedString(@"Open Website", @"")
                         otherBlock:^(void) {
                             NSURL *url = [NSURL URLWithString:@"http://www.followthemoney.org"];
                             if ([[UIApplication sharedApplication] canOpenURL:url])
                                 [[UIApplication sharedApplication] openURL:url];
                         }];
        return;
    }
    
    ContributionsViewController *detail = [[ContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [detail setQueryEntityID:dataObject.entryValue type:dataObject.action cycle:dataObject.parameter];        
    [self stackOrPushViewController:detail];
    [detail release];
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    if (!SLFIsIpad()) {
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    [self.stackController pushViewController:viewController fromViewController:self animated:YES];
}

@end

