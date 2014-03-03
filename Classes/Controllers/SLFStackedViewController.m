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

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad {
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = YES;
    [super viewDidLoad];
    [self.view setNeedsLayout];
}


@end
