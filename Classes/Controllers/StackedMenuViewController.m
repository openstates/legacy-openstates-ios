//
//  StackedMenuViewController.m
//  Created by Gregory Combs on 9/21/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StackedMenuViewController.h"
#import "StackedMenuCell.h"
#import "GradientBackgroundView.h"
#import "AppDelegate.h"

@interface StackedMenuViewController()
- (void)configureMenuBackground;
@end

const NSUInteger STACKED_MENU_INSET = 75;
const NSUInteger STACKED_MENU_WIDTH = 245;

@implementation StackedMenuViewController

- (id)initWithState:(SLFState *)newState {
    NSAssert(SLFIsIpad(), @"This class is only available for iPads (for now)");
    self = [super initWithState:newState];
    if (self) {
        self.useTitleBar = NO;
    }
    return self;
}

- (void)dealloc {
    if (SLFIsIOS5OrGreater())
        [self removeFromParentViewController];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces = NO;
    self.tableView.width = STACKED_MENU_WIDTH;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self configureMenuBackground];
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    [SLFAppDelegateStack popToRootViewControllerAnimated:YES];
    [SLFAppDelegateStack pushViewController:viewController fromViewController:nil animated:YES];
}

- (RKTableViewCellMapping *)menuCellMapping {
    RKTableViewCellMapping *cellMap = [super menuCellMapping];
    cellMap.accessoryType = UITableViewCellAccessoryNone;
    cellMap.style = UITableViewCellStyleDefault;
    cellMap.cellClass = [StackedMenuCell class];
    cellMap.deselectsRowOnSelection = NO;
    cellMap.onCellWillAppearForObjectAtIndexPath = nil;
    return cellMap;
}

- (void)configureMenuBackground {
    self.tableView.separatorColor = SLFColorWithRGBA(44,48,49,0.4);
    GradientBackgroundView *tableBackground = [[GradientBackgroundView alloc] initWithFrame:self.tableView.bounds];
    UIColor *topColor = [SLFAppearance menuBackgroundColor];
    UIColor *stopColor = SLFColorWithRGBShift(topColor, -13);
    UIColor *bottomColor = SLFColorWithRGBShift(topColor, -25);
    [tableBackground loadLayerAndGradientWithColors:[NSArray arrayWithObjects:topColor,stopColor,bottomColor, nil]];
    NSArray *gradientStops = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:.84], [NSNumber numberWithFloat:1.0], nil];
    [(CAGradientLayer *)tableBackground.layer setLocations:gradientStops];
    self.tableView.backgroundView = tableBackground;
    CGPathRef shadowPath = CGPathCreateWithRect(CGRectMake(self.tableView.width-5,0,10,self.tableView.height), NULL);
    self.tableView.layer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tableView.layer.shadowOpacity = .4;
    self.tableView.clipsToBounds = NO;
}

@end

