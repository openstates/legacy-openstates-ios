//
//  ContributionsViewController.m
//  Created by Gregory Combs on 9/15/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "ContributionsViewController.h"
#import "TableCellDataObject.h"
#import "SLFTheme.h"
#import "SLFAlertView.h"
#import "TableSectionHeaderView.h"
#import "GenericDetailHeader.h"

@interface ContributionsViewController()
@end

@implementation ContributionsViewController
@synthesize dataSource;

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
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dataSource = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!dataSource)
        dataSource = [[ContributionsDataSource alloc] init];
    self.tableView.dataSource = dataSource;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDataChanged:) name:kContributionsDataNotifyLoaded object:dataSource];
    
    UILabel *nimsp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.size.width, 66)];
    nimsp.autoresizingMask = UIViewAutoresizingNone;
    nimsp.backgroundColor = [UIColor clearColor];
    nimsp.font = SLFItalicFont(14);
    nimsp.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    nimsp.textAlignment = NSTextAlignmentCenter;
    nimsp.textColor = [SLFAppearance cellTextColor];
    nimsp.lineBreakMode = NSLineBreakByWordWrapping;
    nimsp.numberOfLines = 3;
    nimsp.text = NSLocalizedString(@"Data generously provided by the \nNational Institute on Money in State Politics \nand the Center for Responsive Politics.", @"");
    self.tableView.tableFooterView = nimsp;
    self.screenName = @"Contributions Screen";
}

- (void)updateTableHeader {
    NSDictionary *headerData = SLFTypeDictionaryOrNil(self.dataSource.tableHeaderData);
    if (!headerData) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,1,10)];
        headerView.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = headerView;
        return;
    }
    NSString *title = SLFTypeNonEmptyStringOrNil(headerData[@"title"]);
    NSString *subtitle = SLFTypeNonEmptyStringOrNil(headerData[@"subtitle"]);
    NSString *detail = SLFTypeNonEmptyStringOrNil(headerData[@"detail"]);
    
    CGSize boxSize = CGSizeMake(self.tableView.width, 160);
    CGFloat offsetY = 0;
    if (SLFIsIpad())
        offsetY = 10;
    GenericDetailHeader *detailBox = [[GenericDetailHeader alloc] initWithFrame:CGRectMake(0,offsetY,boxSize.width,boxSize.height-10)];
    detailBox.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    detailBox.defaultSize = boxSize;
    detailBox.title = title;
    detailBox.subtitle = subtitle;
    detailBox.detail = detail;
    [detailBox configure];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,detailBox.width,detailBox.height+(offsetY*2))];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:detailBox];
    self.tableView.tableHeaderView = headerView;
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
    return [TableSectionHeaderView heightForTableViewStyle:self.tableViewStyle];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > [tableView numberOfSections])
        return nil;
    NSString *headerTitle = SLFTypeNonEmptyStringOrNil([self.dataSource tableView:tableView titleForHeaderInSection:section]);
    if (!headerTitle)
        return nil;
    return [[TableSectionHeaderView alloc] initWithTitle:headerTitle width:tableView.frame.size.width style:self.tableViewStyle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableCellDataObject *dataObject = [self.dataSource dataObjectForIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!dataObject || !dataObject.isClickable)
        return;
    if (SLFTypeIsNull(dataObject.entryValue)) {
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
}
/*
- (void)stackOrPushViewController:(UIViewController *)viewController {
    if (!SLFIsIpad()) {
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    [self.stackController pushViewController:viewController fromViewController:self animated:YES];
}*/

@end

