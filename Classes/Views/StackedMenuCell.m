//
//  StackedMenuCell.m
//
//  EventDetailViewController.h
//  Created by Gregory Combs on 9/28/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StackedMenuCell.h"
#import "StackedMenuViewController.h"
#import "SLFTheme.h"
#import "SLFReachable.h"
#import "GradientBackgroundView.h"

@interface StackedMenuCell()
- (void)reachableDidChange:(NSNotification *)notification;
@property(nonatomic,retain) UIView *disabledView;
@end

#define DEFAULT_ITEM_HEIGHT 43.f

@implementation StackedMenuCell
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
        
        GradientInnerShadowView *selectedGradient = [[GradientInnerShadowView alloc] initWithFrame:CGRectMake(0, 0, STACKED_MENU_WIDTH, DEFAULT_ITEM_HEIGHT)];
        self.selectedBackgroundView = selectedGradient;
        [selectedGradient release];
        
        self.backgroundColor = [SLFAppearance menuBackgroundColor];
        self.textLabel.textColor = [SLFAppearance menuTextColor];
        self.textLabel.font = SLFTitleFont(16);
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, STACKED_MENU_WIDTH, 1)];
        topLine.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.25];
        [self addSubview:topLine];
        [topLine release];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, DEFAULT_ITEM_HEIGHT, STACKED_MENU_WIDTH, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        [self addSubview:bottomLine];
        [bottomLine release];
                
        [[SLFReachable sharedReachable].localNotification addObserver:self selector:@selector(reachableDidChange:) name:SLFReachableStatusChangedForHostKey object:SLFReachableAnyNetworkHost];
    }
    return self;
}

- (void)reachableDidChange:(NSNotification *)notification {
    self.enabled = [[SLFReachable sharedReachable] isNetworkReachable];
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
    UIImage *offlineImage = [[UIImage imageNamed:@"offline"] imageWithOverlayColor:[SLFAppearance navBarTextColor]];
    UIImageView *offlineView = [[UIImageView alloc] initWithImage:offlineImage];
    CGFloat imgWidth = offlineImage.size.width;
    CGFloat imgHeight = offlineImage.size.height;
    CGRect frm = CGRectIntegral(CGRectMake(15, (DEFAULT_ITEM_HEIGHT/2) - (imgHeight/2), imgWidth, imgHeight));
    offlineView.frame = frm;
    [newView addSubview:offlineView];        
    [offlineView release];
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
        //[self enableCell];
    }
    else {
        [self showDisabledView];
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
}

- (void)dealloc
{
    [[SLFReachable sharedReachable].localNotification removeObserver:self];
    self.disabledView = nil;
    [super dealloc];
}

@end
