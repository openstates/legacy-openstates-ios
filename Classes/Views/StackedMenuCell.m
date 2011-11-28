//
//  StackedMenuCell.m
//
//  EventDetailViewController.h
//  Created by Gregory Combs on 9/28/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StackedMenuCell.h"
#import "StackedMenuViewController.h"
#import "SLFTheme.h"
#import "SLFReachable.h"
@interface StackedMenuCell()
- (void)reachableDidChange:(NSNotification *)notification;
@end

#define DEFAULT_ITEM_HEIGHT 43.f

@implementation StackedMenuCell
@synthesize glowView = _glowView;
@synthesize enabled = _enabled;
@synthesize disabledView = _disabledView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _enabled = YES;
        self.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeCenter;
        
        UIView* bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.25f];
        self.selectedBackgroundView = bgView;
        [bgView release];
        
        self.backgroundColor = [SLFAppearance menuBackgroundColor];
        self.textLabel.textColor = [SLFAppearance menuTextColor];
        self.textLabel.font = SLFFont(15);
        self.textLabel.highlightedTextColor = [SLFAppearance menuSelectedTextColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 2);
        self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, STACKED_MENU_WIDTH, 1)];
        topLine.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.25];
        [self.textLabel.superview addSubview:topLine];
        [topLine release];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, DEFAULT_ITEM_HEIGHT, STACKED_MENU_WIDTH, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        [self.textLabel.superview addSubview:bottomLine];
        [bottomLine release];
        
        _glowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, DEFAULT_ITEM_HEIGHT)];
        _glowView.image = [UIImage imageNamed:@"MenuGlow"];
        _glowView.hidden = YES;
        [self addSubview:_glowView];
        
        
        [[SLFReachable sharedReachable].localNotification addObserver:self selector:@selector(reachableDidChange:) name:SLFReachableStatusChangedForHostKey object:SLFReachableAnyNetworkHost];
//          RKObjectManager *manager = [RKObjectManager sharedManager];
//          NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//          [center addObserver:self selector:@selector(reachableDidChange:) name:RKObjectManagerDidBecomeOnlineNotification object:manager];
//          [center addObserver:self selector:@selector(reachableDidChange:) name:RKObjectManagerDidBecomeOfflineNotification object:manager];
    }
    return self;
}

- (void)reachableDidChange:(NSNotification *)notification {
    self.enabled = [[SLFReachable sharedReachable] isNetworkReachable];
//  self.enabled = [[RKObjectManager sharedManager] isOnline];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    /* Why can't we do these in viewDidLoad?  For some reason they get reset? */
    CGRect frm = self.imageView.frame;
    self.imageView.frame = CGRectMake(30.f, frm.origin.y, frm.size.width, frm.size.height);
    frm = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(75.f, frm.origin.y, frm.size.width, frm.size.height);    
}

- (void)showDisabledView {
    /* Create the appearance of a "dimmed" table cell, with a standard error icon */
    UIView *newView = [[UIView alloc] initWithFrame:self.bounds];
    newView.backgroundColor = [UIColor colorWithWhite:.5f alpha:.5f];
    
    UIImageView *error = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    CGFloat imgDim = 24.f;
    /* set the error image origin is on the far right side of the table view cell */
    CGRect frm = CGRectMake((STACKED_MENU_WIDTH - 3.f) - imgDim , roundf((DEFAULT_ITEM_HEIGHT/2) - (imgDim/2)), imgDim, imgDim);
    error.frame = frm;
    [newView addSubview:error];        
    [error release];
    [self addSubview:newView];
    [self bringSubviewToFront:newView];
    self.disabledView = newView;
    [newView release];
}

- (void)hideDisabledView {
    if (!self.disabledView)
        return;
    [_disabledView removeFromSuperview];
    self.disabledView = nil;
}

- (void)enableCell {
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.userInteractionEnabled = YES;
}

- (void)disableCell {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = NO;
    if (self.selected) {
        self.selected = NO;
    }
    if (self.highlighted) {
        self.highlighted = NO;
    }
}

- (void)setEnabled:(BOOL)newValue {
    _enabled = newValue;
    if (newValue) {
        [self hideDisabledView];
#warning turn on?
        //[self enableCell];
    }
    else {
        [self showDisabledView];
#warning turn on?
        //[self disableCell];
    }    
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)hil animated:(BOOL)animated {
    [super setHighlighted:hil animated:animated];
    self.textLabel.highlighted = hil;
}

- (void)setSelected:(BOOL)sel animated:(BOOL)animated
{
    [super setSelected:sel animated:animated];
    self.textLabel.highlighted = sel;
    self.glowView.hidden = !sel;
}

- (void)dealloc
{
    [[SLFReachable sharedReachable].localNotification removeObserver:self];
//  [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.disabledView = nil;
    self.glowView = nil;
    [super dealloc];
}
@end
