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
    //#import "StatesViewController.h"

@interface SLFStackedViewController()
@property (nonatomic,retain) IBOutlet StackedNavigationBar *navigationBar;
@property (nonatomic,retain) StatesPopoverManager *statesPopover;
    //@property (nonatomic,retain) StatesViewController *statesPanel;
    //- (IBAction)hideStatesPanel:(id)sender;
    //- (IBAction)showStatesPanel:(id)sender;
@end

@implementation SLFStackedViewController
@synthesize navigationBar = _navigationBar;
@synthesize statesPopover = _statesPopover;
    //@synthesize statesPanel = _statesPanel;

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
        //    self.statesPanel = nil;
    self.navigationBar = nil;
    self.statesPopover = nil;
    [super dealloc];
}

- (void)viewDidUnload {
        //    self.statesPanel = nil;
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

- (IBAction)changeSelectedState:(id)sender {
    if (!sender || ![sender isKindOfClass:[UIView class]])
        sender = _navigationBar;
    self.statesPopover = [StatesPopoverManager showFromOrigin:sender delegate:self];
    //[self showStatesPanel:sender];
}

- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState {
    [self popToRootViewControllerAnimated:YES];
    StackedMenuViewController *vc = (StackedMenuViewController *)self.rootViewController;
    [vc stateMenuSelectionDidChangeWithState:newState];
}

- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover {
    //self.statesPopover = nil;
}

/*
- (IBAction)hideStatesPanel:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;	
    transition.subtype = kCATransitionFromTop;
    [self.statesPanel.view.layer addAnimation:transition forKey:nil];
    self.statesPanel.view.frame = CGRectMake(0, -self.statesPanel.view.frame.size.height, self.statesPanel.view.frame.size.width, self.statesPanel.view.frame.size.height); 
    [self.statesPanel.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
}

- (IBAction)showStatesPanel:(id)sender {
    StatesViewController* stateListVC = [[StatesViewController alloc] init];
    stateListVC.stateMenuDelegate = self;
    stateListVC.view.width = stateListVC.stackWidth;
    stateListVC.view.height = 500.f;
    stateListVC.view.origin = CGPointMake(self.view.center.x - (stateListVC.stackWidth/2), 60);
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;	
    transition.subtype = kCATransitionFromBottom;
    [stateListVC.view.layer addAnimation:transition forKey:nil];
    [self.view addSubview:stateListVC.view];
    self.statesPanel = stateListVC;
    [stateListVC release];
}

- (void)stateMenuSelectionDidChangeWithState:(SLFState *)newState {
    if (self.statesPanel)
        [self hideStatesPanel:self.statesPanel];
    StackedMenuViewController *vc = (StackedMenuViewController *)self.rootViewController;
    [vc stateMenuSelectionDidChangeWithState:newState];
}
*/
@end
