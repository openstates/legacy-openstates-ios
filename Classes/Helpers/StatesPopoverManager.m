//
//  StatesPopoverManager.m
//  Created by Greg Combs on 11/13/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StatesPopoverManager.h"
#import "StatesViewController.h"

@interface StatesPopoverManager()
@property (nonatomic,strong) UIPopoverController *popover;
@property (nonatomic,weak) id<StatesPopoverDelegate>statePopoverDelegate;
@end

@implementation StatesPopoverManager
@synthesize popover = _popover;
@synthesize statePopoverDelegate = _statePopoverDelegate;

- (StatesPopoverManager *)initWithOrigin:(id)origin delegate:(id<StatesPopoverDelegate>)delegate {
    NSParameterAssert(origin != NULL && delegate != NULL);
    self = [super init];
    if (self) {
        self.statePopoverDelegate = delegate;
        StatesViewController* stateListVC = [[StatesViewController alloc] init];
        stateListVC.stateMenuDelegate = self;
        stateListVC.contentSizeForViewInPopover = CGSizeMake(stateListVC.stackWidth, 500.f);
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:stateListVC];    
        _popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        _popover.delegate = self;
        if ([origin isKindOfClass:[UIBarButtonItem class]])
            [_popover presentPopoverFromBarButtonItem:origin permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        else if ([origin isKindOfClass:[UIView class]]) {
            UIView *originView = origin;
            [_popover presentPopoverFromRect:originView.bounds inView:originView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    return self;
}

+ (StatesPopoverManager *)showFromOrigin:(id)origin delegate:(id<StatesPopoverDelegate>)delegate {
    return [[StatesPopoverManager alloc] initWithOrigin:origin delegate:delegate];
}


- (void)dealloc {
    [self dismissPopover:NO];
    self.statePopoverDelegate = nil;
}

- (void)dismissPopover:(BOOL)animated {
    if (!self.popover)
        return;
    if (_popover.isPopoverVisible)
        [_popover dismissPopoverAnimated:animated];
    self.popover = nil;
}

- (void)stateMenuSelectionDidChangeWithState:(SLFState *)newState {
    [self dismissPopover:YES];
    if (self.statePopoverDelegate)
        [self.statePopoverDelegate statePopover:self didSelectState:newState];
}

    // Called whenever the user taps outside the frame of the popover's contents (no need for a "Cancel" button)
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popover = nil;
    if (!self.statePopoverDelegate)
        return;
    if ([_statePopoverDelegate respondsToSelector:@selector(statePopoverDidCancel:)])
        [_statePopoverDelegate statePopoverDidCancel:self];
}

@end
