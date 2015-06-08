//
//  StackedNavigationBar.m
//  Created by Greg Combs on 12/9/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StackedNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "OpenStatesIconView.h"
#import "OpenStatesTitleView.h"
#import "GradientBackgroundView.h"
#import "SLFTheme.h"
    //#import "StackedMenuViewController.h"
#import "SLFState.h"
#import "SLFDrawingExtensions.h"

#define kMapButtonOffsetX (self.width - (62 + 14)) // 62 is the image width
#define kDividerOffsetX (kMapButtonOffsetX - 20)
#define kAccessoryIndicatorOffsetX (kDividerOffsetX - 25)
#define kCenterOffset (5)

@interface AnimatedGradientLayer : CAGradientLayer
@end

@interface ColoredAccessoryIndicator : UIView
@property (nonatomic,retain) UIColor *color;
@end

@interface StackedNavigationBar()
@property (nonatomic,retain) IBOutlet OpenStatesTitleView *titleView;
@property (nonatomic,retain) IBOutlet OpenStatesIconView *iconView;
@property (nonatomic,retain) AnimatedGradientLayer *gradientBar;
@property (nonatomic,retain) IBOutlet UILabel *stateLabel;
- (void)configure;
- (void)createMapButton;
- (void)createAppNameView;
- (void)createShadow;
- (void)resetShadow;
- (void)createDivider;
- (void)createStateLabel;
- (void)createAccessoryIndicator;
- (void)selectedStateDidChange:(NSNotification *)notification;
@end

@implementation StackedNavigationBar
@synthesize titleView = _titleView;
@synthesize iconView = _iconView;
@synthesize gradientBar = _gradientBar;
@synthesize stateLabel = _stateLabel;
@synthesize mapButton = _mapButton;
@synthesize appIconButton = _appIconButton;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) 
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;        
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.titleView = nil;
    self.iconView = nil;
    self.gradientBar = nil;
    self.stateLabel = nil;
    self.mapButton = nil;
    self.appIconButton = nil;
    [super dealloc];
}

- (void)configure {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedStateDidChange:) name:SLFSelectedStateDidChangeNotification object:nil];
    _gradientBar = [AnimatedGradientLayer layer];
    _gradientBar.frame = self.bounds;
    [self.layer addSublayer:_gradientBar];
    [self createAppNameView];
    [self createDivider];
    [self createMapButton];
    [self createShadow];
    [self createStateLabel];
    [self createAccessoryIndicator];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientBar.frame = self.frame;
    [self resetShadow];
}

- (void)createAppNameView {
    CGFloat offsetX = 16;
    CGFloat offsetY = 16;
    if ([[UIDevice currentDevice] systemMajorVersion] >= 7) {
        offsetY +=10;
    }
    _iconView = [[OpenStatesIconView alloc] initWithFrame:CGRectMake(offsetX,offsetY,32,32)];
    _iconView.useDropShadow = NO;
    _iconView.useGradientOverlay = NO;
    _iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    UIImage *iconImage = [UIImage imageFromView:_iconView];
    self.appIconButton = [UIButton buttonForImage:iconImage withFrame:_iconView.frame glossy:NO shadow:NO];
    [self addSubview:_appIconButton];
    offsetX += _iconView.width + 4;
    offsetY += 4;
    CGRect titleRect = CGRectMake(offsetX, offsetY, kOpenStatesTitleViewWidth/1.8, kOpenStatesTitleViewHeight/1.8);
    _titleView = [[OpenStatesTitleView alloc] initWithFrame:CGRectIntegral(titleRect)];
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_titleView];
}

- (void)createMapButton {
    CGFloat offsetY = 10;
    if ([[UIDevice currentDevice] systemMajorVersion] >= 7) {
        offsetY +=10;
    }
    UIImage *image = [UIImage imageNamed:@"MapUSA"];
    self.mapButton = [UIButton buttonForImage:image withFrame:CGRectMake(kMapButtonOffsetX,offsetY,image.size.width,image.size.height) glossy:NO shadow:NO];
    _mapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_mapButton];
}

- (void)createShadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = .4;
    self.layer.borderColor = SLFColorWithRGB(102,103, 98).CGColor;
    self.layer.borderWidth = 1;
}

- (void)resetShadow {
    CGRect shadowRect = CGRectMake(-3,self.height-2,self.width+6,10.0);
    CGPathRef shadowPath = CGPathCreateWithRect(shadowRect, NULL);
    self.layer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
}

- (void)createDivider {
    CGRect dividerRect = CGRectMake(kDividerOffsetX, 0, 1, self.height);
    UIView *left = [[UIView alloc] initWithFrame:dividerRect];
    left.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    left.backgroundColor = SLFColorWithRGB(87,88,82);
    [self addSubview:left];
    [left release];

    dividerRect.origin.x += 1;
    UIView *right = [[UIView alloc] initWithFrame:dividerRect];
    right.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    right.backgroundColor = SLFColorWithRGB(112,113,107);
    [self addSubview:right];
    [right release];
}

- (void)createAccessoryIndicator {
    CGRect viewFrame = CGRectMake(0, 0, 18, 18);
    ColoredAccessoryIndicator *indicator = [[ColoredAccessoryIndicator alloc] initWithFrame:viewFrame];
    indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    indicator.center = CGPointMake(kAccessoryIndicatorOffsetX, self.center.y+kCenterOffset);
    [self addSubview:indicator];
    [indicator release];
}

- (void)createStateLabel {
    CGRect viewFrame = CGRectMake((kAccessoryIndicatorOffsetX - 250) - 20, 0, 250, 22);
    _stateLabel = [[UILabel alloc] initWithFrame:viewFrame];
    _stateLabel.backgroundColor = [UIColor clearColor];
    _stateLabel.font = SLFTitleFont(18);
    _stateLabel.textColor = [SLFAppearance navBarTextColor];
    _stateLabel.textAlignment = NSTextAlignmentRight;
    _stateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _stateLabel.center = CGPointMake(_stateLabel.center.x, self.center.y+kCenterOffset);
    [self selectedStateDidChange:nil];
    [self addSubview:_stateLabel];
}

- (void)selectedStateDidChange:(NSNotification *)notification {
    SLFState *state = SLFSelectedState();
    if (!state)
        _stateLabel.text = NSLocalizedString(@"Choose a State",@"");
    else
        _stateLabel.text = state.name;
}

@end

@implementation AnimatedGradientLayer
- (id)init {
    if (self = [super init]) {
        UIColor *left = [SLFAppearance menuBackgroundColor];
        UIColor *mid = SLFColorWithRGB(110, 111, 103); // at 69%
        UIColor *right = SLFColorWithRGB(93, 94, 89);
        NSArray *finalColors = [NSArray arrayWithObjects:(id)left.CGColor, mid.CGColor, right.CGColor, nil];
        NSNumber *stopOne = [NSNumber numberWithFloat:0];
        NSNumber *stopTwo = [NSNumber numberWithFloat:0.69];
        NSNumber *stopThree = [NSNumber numberWithFloat:1];
        NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, nil];
        self.colors = finalColors;;
        self.locations = locations;
        self.startPoint = CGPointMake(0, 0.5);
        self.endPoint = CGPointMake(1, 0.5);        
    }
    return self;
}
@end


@implementation ColoredAccessoryIndicator
@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = SLFColorWithRGB(81, 84, 86);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    self.color = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    CGFloat x = CGRectGetMaxX(self.bounds)-3.0;
    CGFloat y = CGRectGetMidY(self.bounds);
    const CGFloat R = 4.5;
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctxt, x-R, y-R);
    CGContextAddLineToPoint(ctxt, x, y);
    CGContextAddLineToPoint(ctxt, x-R, y+R);
    CGContextSetLineCap(ctxt, kCGLineCapSquare);
    CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
    CGContextSetLineWidth(ctxt, 3);
    [_color setStroke];    
    CGContextStrokePath(ctxt);
}
@end
