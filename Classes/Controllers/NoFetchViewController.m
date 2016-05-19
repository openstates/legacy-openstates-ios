//
//  LegislatorsNoFetchViewController.m
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "NoFetchViewController.h"
#import "SLFInfoView.h"

@interface NoFetchViewController()
@property (weak, nonatomic,readonly) RKObjectLoader *objectLoader;
@end

@implementation NoFetchViewController
@synthesize state = _state;
@synthesize resourcePath = _resourcePath;
@synthesize dataClass = _dataClass;
@synthesize tableController = _tableController;

- (id)initWithState:(SLFState *)newState resourcePath:(NSString *)path dataClass:(Class)dataClass {
    self = [super init];
    if (self) {
        self.stackWidth = 380;
        self.state = newState;
        self.resourcePath = path;
        self.dataClass = dataClass;
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:(id<RKRequestDelegate>)self.tableController];
    self.dataClass = nil;
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.state];
}

- (void)configureTableController {
    self.tableController = [SLFImprovedRKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.autoRefreshFromNetwork = YES;
    _tableController.autoRefreshRate = 360;
    _tableController.pullToRefreshEnabled = NO;
        //_tableController.imageForError = [UIImage imageNamed:@"error"];
    CGFloat panelWidth = SLFIsIpad() ? self.stackWidth : self.tableView.width;
    SLFInfoView *infoView = [SLFInfoView staticInfoViewWithFrame:CGRectMake(0,0,panelWidth,60) type:SLFInfoTypeActivity title:NSLocalizedString(@"Updating", @"") subtitle:NSLocalizedString(@"Downloading new data",@"") image:nil];
    _tableController.loadingView = infoView;
    [self resetObjectMapping];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:(id<RKRequestDelegate>)self.tableController];
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableController];
    if (self.resourcePath) {
        [_tableController loadTableWithObjectLoader:self.objectLoader];
    }
    self.screenName = @"No Fetch Screen";
}

- (void)setResourcePath:(NSString *)resourcePath {
    SLFRelease(_resourcePath);
    _resourcePath = [resourcePath copy];
    if (self.isViewLoaded && _tableController) {
        [_tableController setValue:[_tableController.objectManager objectLoaderWithResourcePath:resourcePath delegate:(id<RKObjectLoaderDelegate>)_tableController] forKey:@"objectLoader"];
        [self resetObjectMapping];
    }
}

- (void)resetObjectMapping {
    NSParameterAssert(self.dataClass != NULL && _tableController != NULL);
    RKObjectMapping *objectMapping = [_tableController.objectManager.mappingProvider objectMappingForClass:_dataClass];
    [_tableController setValue:objectMapping forKeyPath:@"objectLoader.objectMapping"];
}

- (RKObjectLoader *)objectLoader {
    return [self.tableController valueForKey:@"objectLoader"];
}

- (void)loadTableFromNetwork {
    if (self.resourcePath && self.tableController) {
        [_tableController loadTableWithObjectLoader:self.objectLoader];
    }
}

- (void)resizeLoadingView {
    if (!self.tableController.loadingView)
        return;
    self.tableController.loadingView.width = self.tableView.width;
}

- (void)tableControllerDidStartLoad:(RKAbstractTableController *)tableController {
    [self resizeLoadingView];
}

@end
