//
//  StackedMenuViewController.m
//  Created by Gregory Combs on 9/21/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StackedMenuViewController.h"
#import "AppDelegate.h"
#import "StackedMenuCell.h"
#import "GradientBackgroundView.h"

@interface StackedMenuViewController()
@property (nonatomic,retain) UIColor *backgroundPatternColor;
@property (nonatomic,retain) UIColor *headerPatternColor;
@property (nonatomic,assign) CGFloat headerPatternHeight;

@end

const NSUInteger STACKED_MENU_INSET = 75;
const NSUInteger STACKED_MENU_WIDTH = 200;

@implementation StackedMenuViewController
@synthesize backgroundPatternColor;
@synthesize headerPatternColor;
@synthesize headerPatternHeight;

- (id)initWithState:(SLFState *)newState {
    NSAssert(PSIsIpad(), @"This class is only available for iPads (for now)");
    self = [super initWithState:newState];
    if (self) {
        self.useGradientBackground = NO;
        UIImage *backgroundImage = [UIImage imageNamed:@"MenuPattern"];
        self.backgroundPatternColor = [UIColor colorWithPatternImage:backgroundImage];
        UIImage *headerImage = [UIImage imageNamed:@"HeaderPattern"];
        self.headerPatternHeight = headerImage.size.height;
        self.headerPatternColor = [UIColor colorWithPatternImage:headerImage];
    }
    return self;
}

- (void)dealloc {
    self.backgroundPatternColor = nil;
    self.headerPatternColor = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = self.backgroundPatternColor;
    self.tableView.separatorColor = [UIColor colorWithRed:0.173 green:0.188 blue:0.192 alpha:0.400];
    self.tableView.width = STACKED_MENU_WIDTH;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableViewModel.cellSelectionType = RKTableViewCellSelectionFixed;

    CGRect otherFrame = CGRectMake(STACKED_MENU_WIDTH, 0, self.view.width - STACKED_MENU_WIDTH, self.view.height);
    GradientBackgroundView *gradient = [[GradientBackgroundView alloc] initWithFrame:otherFrame];
    [gradient loadLayerAndGradientColors];
    [self.view addSubview:gradient];
    [gradient release];
    
    otherFrame.size.height = self.headerPatternHeight;
    UIView *headerTopper = [[UIView alloc] initWithFrame:otherFrame];
    headerTopper.backgroundColor = self.headerPatternColor;
    headerTopper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerTopper];
    [headerTopper release];
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    viewController.view.width = 320;
    [XAppDelegate.stackController popToRootViewControllerAnimated:YES];
    [XAppDelegate.stackController pushViewController:viewController fromViewController:nil animated:YES];
}

- (RKTableViewCellMapping *)menuCellMapping {
    RKTableViewCellMapping *cellMap = [RKTableViewCellMapping cellMapping];
    cellMap.accessoryType = UITableViewCellAccessoryNone;
    cellMap.style = UITableViewCellStyleDefault;
    cellMap.cellClass = [StackedMenuCell class];
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        RKTableItem* tableItem = (RKTableItem*) object;
        [self selectMenuItem:tableItem.text];
    };
    return cellMap;
}

@end

