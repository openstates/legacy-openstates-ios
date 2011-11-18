//
//  StackedBackgroundView.m
//  Created by Greg Combs on 11/15/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StackedBackgroundView.h"
#import "OpenStatesIconView.h"
#import "OpenStatesTitleView.h"
#import "GradientBackgroundView.h"
#import "StackedMenuViewController.h"

@interface StackedBackgroundView()
@property (nonatomic,retain) IBOutlet OpenStatesTitleView *titleView;
@property (nonatomic,retain) IBOutlet OpenStatesIconView *iconView;
- (void)createSubviews;
@end

@implementation StackedBackgroundView
@synthesize titleView = _titleView;
@synthesize iconView = _iconView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.autoresizesSubviews = YES;
        self.opaque = YES;
        [self createSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createSubviews];
    }
    return self;
}

- (void)dealloc {
    self.titleView = nil;
    self.iconView = nil;
    [super dealloc];
}

- (void)createSubviews {
    CGRect bounds = self.bounds;
    GradientBackgroundView *gradient = [[GradientBackgroundView alloc] initWithFrame:bounds];
    [gradient loadLayerAndGradientColors];
    [self addSubview:gradient];
    [gradient release];
    
    UIImage *headerImage = [UIImage imageNamed:@"HeaderPattern"];
    CGRect headerFrame = bounds;
    headerFrame.size.height = headerImage.size.height;
    UIView *headerTopper = [[UIView alloc] initWithFrame:headerFrame];
    headerTopper.backgroundColor = [UIColor colorWithPatternImage:headerImage];
    headerTopper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:headerTopper];
    [headerTopper release];
    
    if (!_iconView) {
        CGRect iconRect = CGRectMake(0, 0, kOpenStatesIconViewWidth, kOpenStatesIconViewHeight);
        _iconView = [[OpenStatesIconView alloc] initWithFrame:iconRect];
        [self addSubview:_iconView];
    }
    
    if (!_titleView) {
        CGRect titleRect = CGRectMake(0, 0, kOpenStatesTitleViewWidth, kOpenStatesTitleViewHeight);
        _titleView = [[OpenStatesTitleView alloc] initWithFrame:titleRect];
        [self addSubview:_titleView];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint aCenter = CGPointMake(self.center.x - STACKED_MENU_WIDTH, self.center.y);
    self.iconView.center = aCenter;
    _iconView.frame = CGRectIntegral(_iconView.frame);
    self.titleView.frame = CGRectMake(0, (_iconView.origin.y - 40), kOpenStatesTitleViewWidth, kOpenStatesTitleViewHeight);;
    _titleView.center = CGPointMake(aCenter.x, _titleView.center.y);
    _titleView.frame = CGRectIntegral(_titleView.frame);
}

@end
