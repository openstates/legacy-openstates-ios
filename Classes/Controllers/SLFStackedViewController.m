//
//  SLFStackedViewController.m
//  Created by Greg Combs on 12/9/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFStackedViewController.h"
#import "StackedNavigationBar.h"
#import "StackedMenuViewController.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"

@interface SLFStackedViewController()
@property (nonatomic,retain) IBOutlet StackedNavigationBar *navigationBar;
@property (nonatomic,retain) StatesPopoverManager *statesPopover;
@end

@implementation SLFStackedViewController
@synthesize navigationBar = _navigationBar;
@synthesize statesPopover = _statesPopover;

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.topOffset = 60;
        self.leftInset = STACKED_MENU_INSET;
        self.largeLeftInset = STACKED_MENU_WIDTH;
    }
    return self;
}

- (void)dealloc {
    self.navigationBar = nil;
    self.statesPopover = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.statesPopover = nil;
    self.navigationBar = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar = nil;
    _navigationBar = [[StackedNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
    [self.view addSubview:_navigationBar];
    self.alwaysOnTopSubview = _navigationBar;
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

- (IBAction)changeSelectedState:(id)sender {
    if (!sender || ![sender isKindOfClass:[UIView class]])
        sender = _navigationBar.mapButton;
    self.statesPopover = [StatesPopoverManager showFromOrigin:sender delegate:self];
}

- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState {
    [self popToRootViewControllerAnimated:YES];
    StackedMenuViewController *vc = (StackedMenuViewController *)self.rootViewController;
    [vc stateMenuSelectionDidChangeWithState:newState];
}

- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover {
}

@end
