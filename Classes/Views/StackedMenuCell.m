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

@interface StackedMenuCell()
- (void)setReachability:(NSNotification *)notification;
@end

#define DEFAULT_ITEM_HEIGHT 43.f

@implementation StackedMenuCell
@synthesize glowView;
@synthesize enabled;
@synthesize disabledView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        enabled = YES;
        self.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeCenter;
        
        UIView* bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.25f];
        self.selectedBackgroundView = bgView;
        [bgView release];
        
        self.backgroundColor = [SLFAppearance menuBackgroundColor];
        self.textLabel.textColor = [SLFAppearance menuTextColor];
        self.textLabel.highlightedTextColor = [SLFAppearance menuSelectedTextColor];

        self.textLabel.font = [SLFAppearance boldEighteen];
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
        
        glowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, DEFAULT_ITEM_HEIGHT)];
        glowView.image = [UIImage imageNamed:@"MenuGlow"];
        glowView.hidden = YES;
        [self addSubview:glowView];
        
        RKObjectManager *manager = [RKObjectManager sharedManager];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(setReachability:) name:RKObjectManagerDidBecomeOnlineNotification object:manager];
        [center addObserver:self selector:@selector(setReachability:) name:RKObjectManagerDidBecomeOfflineNotification object:manager];
    }
    return self;
}

- (void)setReachability:(NSNotification *)notification {
    RKObjectManager *manager = [RKObjectManager sharedManager];
    self.enabled = [manager isOnline];
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

- (void)setEnabled:(BOOL)newValue {
    enabled = newValue;
    
    if (enabled) {
        if (self.disabledView) {
            // Remove the "dimmed" view, if there is one. (see below)
            [self.disabledView removeFromSuperview];
            self.disabledView = nil;
        }
        
            // Reenable user interaction and selection ability
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.userInteractionEnabled = YES;
    }
    else {
            /* Create the appearance of a "dimmed" table cell, with a standard error icon */
        UIView *newView = [[UIView alloc] initWithFrame:self.bounds];
        newView.backgroundColor = [UIColor colorWithWhite:.5f alpha:.5f];
        
        UIImageView *error = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
        CGFloat imgDim = 24.f;
            // set the error image's frame origin to be on the far right side of the table view cell
        CGRect frm = CGRectMake((STACKED_MENU_WIDTH - 3.f) - imgDim , roundf((DEFAULT_ITEM_HEIGHT/2) - (imgDim/2)), imgDim, imgDim);
        error.frame = frm;
        [newView addSubview:error];        
        [error release];
         [self addSubview:newView];
        [self bringSubviewToFront:newView];
        self.disabledView = newView;
        [newView release];
        
            // Disable future user interaction and selections
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = NO;
        
            // Turn off any current selections/highlights
        if (self.selected) {
            self.selected = NO;
        }
        if (self.highlighted) {
            self.highlighted = NO;
        }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.disabledView = nil;
    nice_release(glowView);
    [super dealloc];
}
@end
