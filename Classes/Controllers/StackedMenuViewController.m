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
#import "StackedMenuCell.h"
#import "GradientBackgroundView.h"
#import "StretchedTitleLabel.h"
#import "StatesViewController.h"
#import "UIImage+OverlayColor.h"
#import "AppDelegate.h"

@interface StackedMenuViewController()
@property (nonatomic,retain) UIColor *backgroundPatternColor;
@property (nonatomic,retain) UIColor *headerPatternColor;
@property (nonatomic,assign) CGFloat headerPatternHeight;
@property (nonatomic,assign) IBOutlet UIBarButtonItem *selectStateButton;
@property (nonatomic,retain) UILabel *selectedStateLabel;
@property (nonatomic,retain) StatesPopoverManager *statesPopover;
- (void)configureMenuHeader;
- (void)configureMenuFooter;
- (void)configureBackgrounds;
- (IBAction)selectStateFromTable:(id)sender;
- (UIBarButtonItem *)createSelectedStateLabel;
@end

const NSUInteger STACKED_MENU_INSET = 75;
const NSUInteger STACKED_MENU_WIDTH = 200;

@implementation StackedMenuViewController
@synthesize backgroundPatternColor;
@synthesize headerPatternColor;
@synthesize headerPatternHeight;
@synthesize selectStateButton = _selectStateButton;
@synthesize selectedStateLabel = _selectedStateLabel;
@synthesize statesPopover = _statesPopover;

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
    self.selectStateButton = nil;
    self.statesPopover = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = self.backgroundPatternColor;
    self.tableView.separatorColor = [UIColor colorWithRed:0.173 green:0.188 blue:0.192 alpha:0.400];
    self.tableView.width = STACKED_MENU_WIDTH;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableViewModel.cellSelectionType = RKTableViewCellSelectionFixed;

    [self configureBackgrounds];    
    [self configureMenuHeader];
    [self configureMenuFooter];
}

- (void)viewDidUnload {
    self.selectStateButton = nil;
    [super viewDidUnload];
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
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
        if ([tableItem.text hasSuffix:@"News"]) // cheating...
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self selectMenuItem:tableItem.text];
    };
    return cellMap;
}

- (void)configureMenuHeader {
 /*   
    UIImage *headerIcon = [UIImage imageNamed:@"Icon"];
    UIView *menuHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,STACKED_MENU_WIDTH,80.f)];    
    CGFloat iconWidth = 40;
    CGFloat iconInset = 11;
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconInset, iconInset*1.5, iconWidth, iconWidth)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = 3.f;
    imageView.layer.masksToBounds = NO;
    imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    imageView.layer.shadowOffset = CGSizeMake(0, 3);
    imageView.layer.shadowOpacity = 0.5f;
    imageView.layer.shadowRadius = 3.0f;
    imageView.layer.shouldRasterize = YES;
    imageView.image = headerIcon;
    [menuHeader addSubview:imageView];
    [imageView release];
   */
    
    StretchedTitleLabel *titleLabel = CreateOpenStatesTitleLabelForFrame(CGRectMake(0, 0, STACKED_MENU_WIDTH, 44));
    titleLabel.backgroundColor = self.backgroundPatternColor;
    self.tableView.tableHeaderView = titleLabel;
    [titleLabel release];
}


- (void)configureMenuFooter {
    self.selectStateButton = SLFToolbarButton([UIImage imageNamed:@"59-flag"], self, @selector(selectStateFromTable:));
    UIBarButtonItem *stateLabel = [self createSelectedStateLabel];
    UIToolbar *settingsBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height-44, STACKED_MENU_WIDTH, 44)];
    settingsBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [settingsBar setItems:[NSArray arrayWithObjects:_selectStateButton, stateLabel, nil] animated:YES];
    [stateLabel release];
    [self.view addSubview:settingsBar];
    [settingsBar release];
}

- (void)configureBackgrounds {
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

- (IBAction)selectStateFromTable:(id)sender {
    if (!self.selectStateButton) // should never happen
        return;
    self.statesPopover = [StatesPopoverManager showFromBarButtonItem:self.selectStateButton delegate:self];
}

- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState {
    self.statesPopover = nil;
    if (newState && self.selectedStateLabel)
        self.selectedStateLabel.text = [newState.stateID uppercaseString];
    [XAppDelegate.stackController popToRootViewControllerAnimated:YES];
    [super stateMenuSelectionDidChangeWithState:newState];
}

- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover {
    self.statesPopover = nil;
}

- (UIBarButtonItem *)createSelectedStateLabel {
    UILabel *itemLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,30,25)];
    itemLabel.textAlignment = UITextAlignmentLeft;
    itemLabel.textColor = [SLFAppearance menuTextColor];
    itemLabel.font = [SLFAppearance menuTextFont];
    itemLabel.backgroundColor = [UIColor clearColor];
    itemLabel.shadowColor = [UIColor darkGrayColor];
    if (self.state)
        itemLabel.text = [self.state.stateID uppercaseString];    
    UIBarButtonItem *buttonLabel =[[UIBarButtonItem alloc]initWithCustomView:itemLabel];
    self.selectedStateLabel = itemLabel;
    [itemLabel release];    
    return buttonLabel;
}

@end

