//
//  LegislatorsViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorsViewController.h"
#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "LegislatorCell.h"

@implementation LegislatorsViewController
@synthesize state;
@synthesize tableViewModel;
@synthesize resourcePath;

- (id)initWithState:(SLFState *)newState {
    self = [super init];
    if (self) {
        self.state = newState;
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     SUNLIGHT_APIKEY,@"apikey", 
                                     @"true", @"active", 
                                     newState.stateID,@"state", nil];
        self.resourcePath = RKMakePathWithObject(@"/legislators?state=:state&active=:active&apikey=:apikey", queryParams);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Loading...",@"");
    self.tableViewModel = [RKFetchedResultsTableViewModel tableViewModelForTableViewController:(UITableViewController*)self];
    self.tableViewModel.delegate = self;
    self.tableViewModel.objectManager = [RKObjectManager sharedManager];
    self.tableViewModel.resourcePath = self.resourcePath;
    [self.tableViewModel setObjectMappingForClass:[SLFLegislator class]];
    self.tableViewModel.autoRefreshFromNetwork = YES;
    self.tableViewModel.variableHeightRows = YES;
    self.tableViewModel.autoRefreshRate = 360;
    self.tableViewModel.pullToRefreshEnabled = YES;
    self.tableViewModel.showsSectionIndexTitles = YES;
    self.tableViewModel.sectionNameKeyPath = @"lastnameInitial";
    
    LegislatorCellMapping *objCellMap = [LegislatorCellMapping cellMappingWithBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"self" toAttribute:@"legislator"];
        
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            SLFLegislator *legislator = object;
            LegislatorDetailViewController *vc = [[LegislatorDetailViewController alloc] initWithLegislatorID:legislator.legID];
            [self stackOrPushViewController:vc];
            [vc release];
            
        };
    }];
    [self.tableViewModel mapObjectsWithClass:[SLFLegislator class] toTableCellsWithMapping:objCellMap];    
    [self.tableViewModel loadTable];
    self.title = [NSString stringWithFormat:@"%d Members",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)tableViewModelDidFinishLoad:(RKAbstractTableViewModel*)tableViewModel {
    self.title = [NSString stringWithFormat:@"%d Members",[[self.tableViewModel.fetchedResultsController fetchedObjects] count]];
}

- (void)dealloc {
    self.tableViewModel = nil;
    self.state = nil;
    self.resourcePath = nil;
    [super dealloc];
}

@end
