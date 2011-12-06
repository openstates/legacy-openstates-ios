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
#import "StatesViewController.h"
#import "UIImage+OverlayColor.h"
#import "StackedBackgroundView.h"
#import "DDActionHeaderView.h"
#import "OpenStatesIconView.h"
#import "UIImageView+RoundedCorners.h"
#import "SLFDrawingExtensions.h"

@interface StackedMenuViewController()
@property (nonatomic,retain) UIColor *backgroundPatternColor;
@property (nonatomic,assign) IBOutlet UIButton *selectStateButton;
@property (nonatomic,retain) StatesPopoverManager *statesPopover;
- (void)configureMenuHeader;
- (void)configureMenuFooter;
- (void)configureStackedBackgroundView;
- (void)configureActionBarForState:(SLFState *)newState;
- (void)handleStatePickerBarTap:(UIGestureRecognizer *)gestureRecognizer;
@end

const NSUInteger STACKED_MENU_INSET = 75;
const NSUInteger STACKED_MENU_WIDTH = 200;

@implementation StackedMenuViewController
@synthesize backgroundPatternColor;
@synthesize selectStateButton = _selectStateButton;
@synthesize statesPopover = _statesPopover;

- (id)initWithState:(SLFState *)newState {
    NSAssert(SLFIsIpad(), @"This class is only available for iPads (for now)");
    self = [super initWithState:newState];
    if (self) {
        self.useGradientBackground = NO;
        UIImage *backgroundImage = [UIImage imageNamed:@"MenuPattern"];
        self.backgroundPatternColor = [UIColor colorWithPatternImage:backgroundImage];
    }
    return self;
}

- (void)dealloc {
    self.backgroundPatternColor = nil;
    self.selectStateButton = nil;
    self.statesPopover = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.selectStateButton = nil;
    self.statesPopover = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = self.backgroundPatternColor;
    self.tableView.separatorColor = [UIColor colorWithRed:0.173 green:0.188 blue:0.192 alpha:0.400];
    self.tableView.width = STACKED_MENU_WIDTH;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableViewModel.cellSelectionType = RKTableViewCellSelectionFixed;

    [self configureStackedBackgroundView];    
    [self configureMenuHeader];
    [self configureMenuFooter];
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    [SLFAppDelegateStack popToRootViewControllerAnimated:YES];
    [SLFAppDelegateStack pushViewController:viewController fromViewController:nil animated:YES];
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
    [self.titleBarView removeFromSuperview];
    DDActionHeaderView *actionBar = [[DDActionHeaderView alloc] initWithFrame:CGRectMake(0, 0, STACKED_MENU_WIDTH, 70)];
    actionBar.autoresizingMask = UIViewAutoresizingNone;
    actionBar.useGradientBorder = NO;
    actionBar.strokeBottomColor = [UIColor colorWithWhite:0.5 alpha:0.25];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStatePickerBarTap:)];
	tapGesture.delegate = self;
	[actionBar addGestureRecognizer:tapGesture];
	[tapGesture release];	

    self.titleBarView = actionBar;
    [self.view addSubview:actionBar];
    [actionBar release];
    [self configureActionBarForState:self.state];
}

- (void)configureMenuFooter {
    /*
    self.selectStateButton = SLFToolbarButton([UIImage imageNamed:@"59-flag"], self, @selector(changeSelectedState:));
    UIBarButtonItem *stateLabel = [self createSelectedStateLabel];
    UIToolbar *settingsBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height-44, STACKED_MENU_WIDTH, 44)];
    settingsBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [settingsBar setItems:[NSArray arrayWithObjects:_selectStateButton, stateLabel, nil] animated:YES];
    [stateLabel release];
    [self.view addSubview:settingsBar];
    [settingsBar release];*/
}

- (void)configureStackedBackgroundView {
    CGRect viewFrame = CGRectMake(STACKED_MENU_WIDTH, 0, self.view.size.width - STACKED_MENU_WIDTH, self.view.size.height);
    StackedBackgroundView *background = [[StackedBackgroundView alloc] initWithFrame:viewFrame];
    [self.view addSubview:background];
    [background release];
}

- (IBAction)changeSelectedState:(id)sender {
    if (!sender || ![sender isKindOfClass:[UIView class]])
        sender = self.selectStateButton;
    self.statesPopover = [StatesPopoverManager showFromOrigin:sender delegate:self];
}

- (void)statePopover:(StatesPopoverManager *)statePopover didSelectState:(SLFState *)newState {
    [self configureActionBarForState:newState];
    [SLFAppDelegateStack popToRootViewControllerAnimated:YES];
    [super stateMenuSelectionDidChangeWithState:newState];
}

- (void)statePopoverDidCancel:(StatesPopoverManager *)statePopover {
        //self.statesPopover = nil;
}

- (UIButton *)barButtonForState:(SLFState *)aState {
    UIButton *button;
    if (aState)
        button = [UIButton buttonForImage:aState.stateFlag withFrame:CGRectMake( 6, 8, 48, 32 ) glossy:YES];
    else {
        OpenStatesIconView *iconView = [[OpenStatesIconView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        iconView.useDropShadow = NO;
        button = [UIButton buttonForImage:[UIImage imageFromView:iconView] withFrame:CGRectMake( 11, 6, 40, 40 ) glossy:NO];
        [iconView release];
    }
    [button addTarget:self action:@selector(changeSelectedState:) forControlEvents:UIControlEventTouchUpInside]; 
    return button;
}

- (void)configureActionBarForState:(SLFState *)newState {
    DDActionHeaderView *actionBar = (DDActionHeaderView *)self.titleBarView;
    if (!actionBar)
        return;
    if ([actionBar isActionPickerExpanded])
        [actionBar shrinkActionPicker];
    self.selectStateButton = [self barButtonForState:newState];
    CGPoint origin = CGPointMake(_selectStateButton.bounds.size.width + 16, 16);
    UILabel *innerLabel = SLFStyledHeaderLabelWithTextAtOrigin(NSLocalizedString(@"Pick a State", @""), origin);
    actionBar.items = [NSArray arrayWithObjects:_selectStateButton, innerLabel, nil];
    if (!newState)
        self.title = NSLocalizedString(@"Pick a State: ", @"");
    [self.view setNeedsDisplayInRect:actionBar.frame];
}

- (void)handleStatePickerBarTap:(UIGestureRecognizer *)gestureRecognizer {
    NSUInteger stackSize = [SLFAppDelegateStack canExpandStack];
    if (stackSize) {
        [SLFAppDelegateStack displayViewControllerIndexOnRightMost:-stackSize animated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [SLFAppDelegateStack canExpandStack];
}

@end

