//
//  AssetsViewController.m
//  Created by Greg Combs on 1/4/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "AssetsViewController.h"
#import "SLFDataModels.h"
#import "NSString+SLFExtensions.h"
#import "SLFReachable.h"
#import "SLFImprovedRKTableController.h"
@import SafariServices;

@interface AssetsViewController()

@property (nonatomic, strong) SLFImprovedRKTableController *tableController;
@property (nonatomic, strong) id assetResource;

- (RKTableViewCellMapping *)assetCellMap;
- (void)configureTableItems;

@end

@implementation AssetsViewController
@synthesize assets = _assets;
@synthesize tableController = _tableController;
@synthesize assetResource = _assetResource;

/* A silly assumption that we're pulling up capitol maps, but it solves a path navigator issue, 
   and it's unlikely we'll need to navigate to something else using the same initializer */
- (id)initWithState:(SLFState *)state {
    NSArray *assets = nil;
    NSString *title = NSLocalizedString(@"Capitol Maps", @"");
    if (state) {
        assets = state.sortedCapitolMaps;
        title = [NSString stringWithFormat:@"%@ %@", state.name, title];
    }
    self = [self initWithAssets:assets];
    if (self) {
        self.useTitleBar = SLFIsIpad();
        self.title = title;
        if (state)
            self.assetResource = state;
    }
    return self;
}

- (id)initWithAssets:(NSArray *)assets {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.stackWidth = 380;
        self.assets = assets;
    }
    return self;
}


- (void)viewDidUnload {
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableController = [SLFImprovedRKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.variableHeightRows = NO;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    [_tableController mapObjectsWithClass:[GenericAsset class] toTableCellsWithMapping:[self assetCellMap]];
    [self configureTableItems];
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.assetResource];
}

- (void)configureTableItems {
    if (!self.assets)
        return;
    [_tableController loadObjects:_assets];    
}

#pragma mark - Table Item Creation and Mapping

- (RKTableViewCellMapping *)assetCellMap {
    StyledCellMapping *cellMap = [StyledCellMapping subtitleMapping];
    [cellMap mapKeyPath:@"name" toAttribute:@"textLabel.text"];
    [cellMap mapKeyPath:@"fileName" toAttribute:@"detailTextLabel.text"];
    __weak __typeof__(self) wSelf = self;
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
        __strong __typeof__(wSelf) sSelf = wSelf;
        GenericAsset *asset = object;

        NSURL *URL = [NSURL URLWithString:asset.url];
        if (!URL.scheme || ![@[@"https",@"http"] containsObject:URL.scheme])
            return;

        __weak __typeof__(self) wSelf = sSelf;
        SLFReachabilityCompletionHandler completion = ^(NSURL *url, BOOL isReachable){
            if (!isReachable)
                return;

            SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:NO];
            webViewController.title = asset.name;
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            [wSelf presentViewController:webViewController animated:YES completion:nil];
        };

        SLFIsReachableAddressAsync(URL,completion);
    };
    return cellMap;
}

@end
