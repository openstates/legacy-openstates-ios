//
//  StatesPopoverManager.m
//  Created by Greg Combs on 11/13/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StatesPopoverManager.h"
#import "StatesViewController.h"

@interface StatesPopoverManager()
@property (nonatomic,retain) UIPopoverController *popover;
@property (nonatomic,assign) id<StatesPopoverDelegate>statePopoverDelegate;
@end

@implementation StatesPopoverManager
@synthesize popover = _popover;
@synthesize statePopoverDelegate = _statePopoverDelegate;

- (StatesPopoverManager *)initWithBarButtonItem:(UIBarButtonItem *)button delegate:(id<StatesPopoverDelegate>)delegate {
    NSParameterAssert(button != NULL && delegate != NULL);
    self = [super init];
    if (self) {
        self.statePopoverDelegate = delegate;
        StatesViewController* stateListVC = [[StatesViewController alloc] init];
        stateListVC.stateMenuDelegate = self;
        stateListVC.contentSizeForViewInPopover = CGSizeMake(stateListVC.stackWidth, 500.f);
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:stateListVC];    
        [stateListVC release];
        _popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        _popover.delegate = self;
        [navController release];
        [_popover presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    return self;
}

+ (StatesPopoverManager *)showFromBarButtonItem:(UIBarButtonItem *)button delegate:(id<StatesPopoverDelegate>)delegate {
    return [[[StatesPopoverManager alloc] initWithBarButtonItem:button delegate:delegate] autorelease];
}


- (void)dealloc {
    [self dismissPopover:NO];
    self.statePopoverDelegate = nil;
    [super dealloc];
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
