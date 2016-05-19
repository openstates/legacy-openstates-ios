//
//  SLFStackedViewController.m
//  Created by Greg Combs on 12/9/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFStackedViewController.h"
#import "AppBarController.h"
#import "StackedMenuViewController.h"
#import "SLFReachable.h"

@interface SLFStackedViewController()
@end

@implementation SLFStackedViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.leftInset = STACKED_MENU_INSET;
        self.largeLeftInset = STACKED_MENU_WIDTH;
        if ([self respondsToSelector:@selector(extendedLayoutIncludesOpaqueBars)]) {
            self.extendedLayoutIncludesOpaqueBars = YES;
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }

    }
    return self;
}


- (void)viewDidLoad {
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    [super viewDidLoad];
    [self.view setNeedsLayout];
}


@end
