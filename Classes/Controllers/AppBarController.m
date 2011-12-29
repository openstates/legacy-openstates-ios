//
//  AppBarController.m
//  Created by Greg Combs on 12/19/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "AppBarController.h"
#import "StackedNavigationBar.h"
#import "SLFStackedViewController.h"
#import "StackedMenuViewController.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"
#import "StackedBackgroundView.h"

const NSUInteger STACKED_NAVBAR_HEIGHT = 60;

@interface AppBarController()
@property (nonatomic,retain) IBOutlet StackedNavigationBar *navigationBar;
@property (nonatomic,retain) StatesPopoverManager *statesPopover;
@property (nonatomic,retain) SLFStackedViewController *stackedViewController;
- (void)configureBackgroundView;
@end

@implementation AppBarController

@synthesize navigationBar = _navigationBar;
@synthesize statesPopover = _statesPopover;
@synthesize stackedViewController = _stackedViewController;


- (void)dealloc {
    self.navigationBar = nil;
    self.statesPopover = nil;
    self.stackedViewController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.statesPopover = nil;
    self.navigationBar = nil;
    self.stackedViewController = nil;
    [super viewDidUnload];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stackedViewController = nil;
    SLFState *foundSavedState = SLFSelectedState();
    StackedMenuViewController* stateMenuVC = [[StackedMenuViewController alloc] initWithState:foundSavedState];
    stateMenuVC.view.frame = CGRectMake(0, 0, STACKED_MENU_WIDTH, self.view.frame.size.height);
    _stackedViewController = [[SLFStackedViewController alloc] initWithRootViewController:stateMenuVC];
    _stackedViewController.view.frame = CGRectMake(0, STACKED_NAVBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - STACKED_NAVBAR_HEIGHT);
    if (SLFIsIOS5OrGreater())
        [self addChildViewController:_stackedViewController];
    [self.view addSubview:_stackedViewController.view];
    self.navigationBar = nil;
    _navigationBar = [[StackedNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, STACKED_NAVBAR_HEIGHT)];
    [self.view addSubview:_navigationBar];
    [_navigationBar.mapButton addTarget:self action:@selector(changeSelectedState:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationBar.appIconButton addTarget:self action:@selector(browseToAppWebSite:) forControlEvents:UIControlEventTouchUpInside];
    SLFRunBlockAfterDelay(^{
            // Give the persistent data a chance to materialize, and give time to instantiate the infrastructure.
        if (IsEmpty(SLFSelectedStateID())) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[StatesViewController class] withResource:nil];
            [SLFActionPathNavigator navigateToPath:path skipSaving:YES fromBase:nil popToRoot:NO];
        }
    },.3);
    [stateMenuVC release];
    [self configureBackgroundView];
}

- (void)configureBackgroundView {
    CGRect viewFrame = CGRectMake(STACKED_MENU_WIDTH, STACKED_NAVBAR_HEIGHT, self.view.width - STACKED_MENU_WIDTH, self.view.height - STACKED_NAVBAR_HEIGHT);
    StackedBackgroundView *background = [[StackedBackgroundView alloc] initWithFrame:viewFrame];
    [self.view insertSubview:background atIndex:0];
    [background release];
}

- (IBAction)changeSelectedState:(id)sender {
    if (!sender || ![sender isKindOfClass:[UIView class]])
        sender = _navigationBar.mapButton;
    self.statesPopover = [StatesPopoverManager showFromOrigin:sender delegate:self];
}

- (IBAction)browseToAppWebSite:(id)sender {
    NSString *url = NSLocalizedString(@"http://openstates.org", @"App Website");
    if (SLFIsReachableAddress(url)) {
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:webViewController animated:YES];	
        [webViewController release];
    }
}

- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState {
    [_stackedViewController popToRootViewControllerAnimated:YES];
    StackedMenuViewController *vc = (StackedMenuViewController *)(_stackedViewController.rootViewController);
    [vc stateMenuSelectionDidChangeWithState:newState];
}

- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
@end
