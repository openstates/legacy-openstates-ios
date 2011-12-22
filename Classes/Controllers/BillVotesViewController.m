//
//  BillVotesViewController.m
//  Created by Greg Combs on 11/21/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "BillVotesViewController.h"
#import "SLFDataModels.h"
#import "TableSectionHeaderView.h"
#import "NSString+SLFExtensions.h"
#import "NSDate+SLFDateHelper.h"
#import "LegislatorDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+RoundedCorners.h"
#import "LegislatorCell.h"

enum SECTIONS {
    SectionVoteInfo = 1,
    SectionYes,
    SectionNo,
    SectionOther,
    kNumSections
};

@interface BillVotesViewController()
@property (nonatomic, retain) RKTableController *tableController;
- (RKTableViewCellMapping *)voterCellMap;
- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex;
- (void)configureTableItems;
- (void)configureVoteInfo;
- (void)configureVoters;
@end

@implementation BillVotesViewController
@synthesize vote = _vote;
@synthesize tableController = _tableController;

- (id)initWithVote:(BillRecordVote *)vote {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.stackWidth = 500;
        self.vote = vote;
    }
    return self;
}

- (void)dealloc {
    self.vote = nil;
    self.tableController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.variableHeightRows = YES;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    [_tableController mapObjectsWithClass:[BillVoter class] toTableCellsWithMapping:[self voterCellMap]];
    NSInteger sectionIndex;
    for (sectionIndex = SectionVoteInfo;sectionIndex < kNumSections; sectionIndex++) {
        [_tableController addSectionUsingBlock:^(RKTableSection *section) {
            NSString *headerTitle = [self headerForSectionIndex:sectionIndex];
            TableSectionHeaderView *headerView = [[TableSectionHeaderView alloc] initWithTitle:headerTitle width:self.tableView.width];
            section.headerTitle = headerTitle;
            section.headerHeight = TableSectionHeaderViewDefaultHeight;
            section.headerView = headerView;
            [headerView release];
        }];
    }
    [self configureTableItems];
}

- (void)configureTableItems {
    if (!self.vote)
        return;
    self.title = _vote.title;
    [self configureVoteInfo];     
    [self configureVoters];
}

#pragma mark - Table Item Creation and Mapping

- (void)configureVoteInfo {
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Chamber", @"");
        tableItem.detailText = _vote.chamberObj.formalName;
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        NSString *caption = [_vote.date stringForDisplay];
        if (!IsEmpty(_vote.session))
            caption = [NSString stringWithFormat:@"%@ (%@)", [_vote.date stringForDisplay], _vote.session];
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Date", @"");
        tableItem.detailText = caption;
    }]];
    if (!IsEmpty(_vote.motion)) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
            NSString *caption = [_vote.motion capitalizedString];
            if (!IsEmpty(_vote.record))
                caption = [NSString stringWithFormat:@"%@ (%@)", caption, _vote.record];
            tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
            tableItem.text = NSLocalizedString(@"Motion", @"");
            tableItem.detailText = caption;
        }]];
    }
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [StaticSubtitleCellMapping cellMapping];
        tableItem.text = NSLocalizedString(@"Status", @"");
        tableItem.detailText = _vote.subtitle;
    }]];
    [self.tableController loadTableItems:tableItems inSection:SectionVoteInfo];     
    [tableItems release];
}

- (void)configureVoters {
    [_tableController loadObjects:_vote.sortedYesVotes inSection:SectionYes];    
    [_tableController loadObjects:_vote.sortedNoVotes inSection:SectionNo];    
    [_tableController loadObjects:_vote.sortedOtherVotes inSection:SectionOther];    
}

- (RKTableViewCellMapping *)voterCellMap {
    FoundLegislatorCellMapping *cellMapping = [FoundLegislatorCellMapping cellMapping];
    [cellMapping mapKeyPath:@"foundLegislator" toAttribute:@"legislator"];
    [cellMapping mapKeyPath:@"type" toAttribute:@"role"];
    [cellMapping mapKeyPath:@"name" toAttribute:@"genericName"];
    cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        if (cellMapping.roundImageCorners) {
            NSInteger numRows = [self.tableController tableView:self.tableView numberOfRowsInSection:indexPath.section];
            if (numRows == 1)
                [cell.imageView roundTopAndBottomLeftCorners];
            else if (indexPath.row == 0)
                [cell.imageView roundTopLeftCorner];
            else if (indexPath.row == (numRows-1))
                [cell.imageView roundBottomLeftCorner];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 50.f)];
		cell.accessoryView = imageView;
        BillVoter *voter = object;
        if (!IsEmpty([voter yesVoteInverse]))
            imageView.image = [UIImage imageNamed:@"VoteYea"];
        else if (!IsEmpty([voter noVoteInverse]))
            imageView.image = [UIImage imageNamed:@"VoteNay"];
        else if (!IsEmpty([voter otherVoteInverse]))
            imageView.image = [UIImage imageNamed:@"VotePNV"];
        [imageView release];
        BOOL useDarkBG = SLFAlternateCellForIndexPath(cell, indexPath);
        [(LegislatorCell *)cell setUseDarkBackground:useDarkBG];
    };
    cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        NSString *legID = [object valueForKey:@"legID"];
        NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResourceID:legID];
        if (!IsEmpty(path))
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:self popToRoot:NO];
    };
    return cellMapping;
}

- (NSString *)headerForSectionIndex:(NSInteger)sectionIndex {
    switch (sectionIndex) {
        case SectionVoteInfo:
            return NSLocalizedString(@"Vote Details", @"");
        case SectionYes:
            return NSLocalizedString(@"Yeas",@"");
        case SectionNo:
            return NSLocalizedString(@"Nays",@"");
        case SectionOther:
            return NSLocalizedString(@"Others (PNV, Absent, etc)", @"");
        default:
            return @"";
    }
}
@end
