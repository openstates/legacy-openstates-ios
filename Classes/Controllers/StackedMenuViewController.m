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

const NSUInteger STACKED_MENU_INSET = 80;
const NSUInteger STACKED_MENU_WIDTH = 200;

@implementation StackedMenuViewController

- (id)initWithState:(SLFState *)newState {
    NSAssert(PSIsIpad(), @"This class is only available for iPads (for now)");
    self = [super initWithState:newState];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *patternImage = [UIImage imageNamed:@"MenuPattern"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    self.tableView.separatorColor = [UIColor colorWithRed:0.173 green:0.188 blue:0.192 alpha:0.400];
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.width = STACKED_MENU_WIDTH;
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    [XAppDelegate.stackController popToRootViewControllerAnimated:YES];
    [XAppDelegate.stackController pushViewController:viewController fromViewController:nil animated:YES];
}

- (RKTableViewCellMapping *)menuCellMapping {
    RKTableViewCellMapping *cellMap = [RKTableViewCellMapping cellMapping];
    cellMap.accessoryType = UITableViewCellAccessoryNone;
    cellMap.style = UITableViewCellStyleDefault;
    cellMap.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        RKTableItem* tableItem = (RKTableItem*) object;
        [self selectMenuItem:tableItem.text];
    };
    cellMap.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        cell.backgroundColor = [SLFAppearance menuBackgroundColor];
        cell.textLabel.textColor = [SLFAppearance menuTextColor];
    };
    return cellMap;
}

@end

