//
//  AppBarController.m
//  Created by Greg Combs on 12/19/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "AppBarController.h"
#import "StackedNavigationBar.h"
#import "SLFStackedViewController.h"
#import "StackedMenuViewController.h"
#import "SLFReachable.h"
#import "StackedBackgroundView.h"
@import SafariServices;

const NSUInteger STACKED_NAVBAR_HEIGHT = 60;

@interface AppBarController()
@property (nonatomic,strong) IBOutlet StackedNavigationBar *navigationBar;
@property (nonatomic,strong) StatesPopoverManager *statesPopover;
@property (nonatomic,strong) SLFStackedViewController *stackedViewController;
@property (nonatomic,strong) StackedBackgroundView *backgroundView;
- (void)configureBackgroundView;
@end

@implementation AppBarController

@synthesize navigationBar = _navigationBar;
@synthesize statesPopover = _statesPopover;
@synthesize stackedViewController = _stackedViewController;
@synthesize backgroundView = _backgroundView;


- (void)viewDidUnload {
    self.statesPopover = nil;
    self.navigationBar = nil;
    self.stackedViewController = nil;
    self.backgroundView = nil;
    [super viewDidUnload];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stackedViewController = nil;
    CGFloat navBarHeight = STACKED_NAVBAR_HEIGHT;
    if ([[UIDevice currentDevice] systemMajorVersion] >= 7) {
        navBarHeight += 6;
    }

    SLFState *foundSavedState = SLFSelectedState();
    StackedMenuViewController* stateMenuVC = [[StackedMenuViewController alloc] initWithState:foundSavedState];
    stateMenuVC.view.frame = CGRectMake(0, 0, STACKED_MENU_WIDTH, self.view.frame.size.height);
    _stackedViewController = [[SLFStackedViewController alloc] initWithRootViewController:stateMenuVC];
    _stackedViewController.view.frame = CGRectMake(0, navBarHeight, self.view.frame.size.width, self.view.frame.size.height - navBarHeight);
    if (SLFIsIOS5OrGreater())
        [self addChildViewController:_stackedViewController];
    [self.view addSubview:_stackedViewController.view];
    if (SLFIsIOS5OrGreater())
        [_stackedViewController didMoveToParentViewController:self];
    self.navigationBar = nil;
    _navigationBar = [[StackedNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, navBarHeight)];
    [self.view addSubview:_navigationBar];
    [_navigationBar.mapButton addTarget:self action:@selector(changeSelectedState:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationBar.appIconButton addTarget:self action:@selector(browseToAppWebSite:) forControlEvents:UIControlEventTouchUpInside];
    SLFRunBlockAfterDelay(^{
            // Give the persistent data a chance to materialize, and give time to instantiate the infrastructure.
        if (!SLFTypeNonEmptyStringOrNil(SLFSelectedStateID())) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[StatesViewController class] withResource:nil];
            [SLFActionPathNavigator navigateToPath:path skipSaving:YES fromBase:nil popToRoot:NO];
        }
    },.3);
    [self configureBackgroundView];
}

- (void)configureBackgroundView {
    CGFloat viewTop = 0.0;
    if ([[UIDevice currentDevice] systemMajorVersion] < 7) {
        viewTop = -20.0f;
    }
    CGRect viewFrame = CGRectMake(STACKED_MENU_WIDTH, viewTop, self.view.width - STACKED_MENU_WIDTH, self.view.height);
    _backgroundView = [[StackedBackgroundView alloc] initWithFrame:viewFrame];
    [self.view insertSubview:_backgroundView atIndex:0];
}

- (void)didReceiveMemoryWarning {
    if (self.isViewLoaded && _backgroundView) {
        [_backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    [super didReceiveMemoryWarning];
}

- (IBAction)changeSelectedState:(id)sender {
    if (!sender || ![sender isKindOfClass:[UIView class]])
        sender = _navigationBar.mapButton;
    self.statesPopover = [StatesPopoverManager showFromOrigin:sender delegate:self];
}

- (IBAction)browseToAppWebSite:(id)sender {
    NSString *urlString = NSLocalizedString(@"http://openstates.org", @"App Website");
    NSURL *URL = [NSURL URLWithString:urlString];
    if (!URL.scheme || ![@[@"https",@"http"] containsObject:URL.scheme])
        return;

    __weak __typeof__(self) wSelf = self;
    SLFReachabilityCompletionHandler completion = ^(NSURL *url, BOOL isReachable){
        if (!isReachable)
            return;

        SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:NO];
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        [wSelf presentViewController:webViewController animated:YES completion:nil];
    };

    SLFIsReachableAddressAsync(URL,completion);
}

- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState {
    [self.stackedViewController popToRootViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StackedMenuViewController *vc = (StackedMenuViewController *)(self.stackedViewController.rootViewController);
        [vc stateMenuSelectionDidChangeWithState:newState];
    });
}

- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
@end
