//
//  StackedNavigationBar.m
//  Created by Greg Combs on 12/9/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StackedNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "OpenStatesIconView.h"
#import "OpenStatesTitleView.h"
#import "GradientBackgroundView.h"
#import "SLFTheme.h"
#import "StackedMenuViewController.h"

#define kMapButtonOffsetX (self.width - (62 + 14)) // 62 is the image width
#define kDividerOffsetX (kMapButtonOffsetX - 20)
#define kAccessoryIndicatorOffsetX (kDividerOffsetX - 25)
#define kStateLabelRect CGRectMake((kAccessoryIndicatorOffsetX - 250) - 20,23,250,22)

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
    CGRect shadowRect = CGRectMake(-3,self.height,self.width+6,10.0);
    CGPathRef shadowPath = CGPathCreateWithRect(shadowRect, NULL);
    self.layer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
}

- (void)createAppNameView {
    CGFloat offsetX = 16;
    CGFloat offsetY = 16;
    _iconView = [[OpenStatesIconView alloc] initWithFrame:CGRectMake(offsetX,offsetY,32,32)];
    _iconView.useDropShadow = NO;
    _iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_iconView];
    offsetX += _iconView.width;
    offsetY += 4;
    CGRect titleRect = CGRectMake(offsetX, offsetY, kOpenStatesTitleViewWidth/1.8, kOpenStatesTitleViewHeight/1.8);
    _titleView = [[OpenStatesTitleView alloc] initWithFrame:CGRectIntegral(titleRect)];
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_titleView];
}

- (void)createMapButton {
    UIImage *image = [UIImage imageNamed:@"MapUSA"];    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    button.opaque = YES;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:SLFAppDelegateStack action:@selector(changeSelectedState:) forControlEvents:UIControlEventTouchUpInside];
    button.origin = CGPointMake(kMapButtonOffsetX, 10);
    [self addSubview:button];
}

- (void)createShadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = .4;
    self.layer.borderColor = SLFColorWithRGB(102,103, 98).CGColor;
    self.layer.borderWidth = 1;
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
    ColoredAccessoryIndicator *indicator = [[ColoredAccessoryIndicator alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    indicator.center = CGPointMake(kAccessoryIndicatorOffsetX, self.center.y+4);
    [self addSubview:indicator];
    [indicator release];
}

- (void)createStateLabel {
    _stateLabel = [[UILabel alloc] initWithFrame:kStateLabelRect];
    _stateLabel.backgroundColor = [UIColor clearColor];
    _stateLabel.font = SLFTitleFont(18);
    _stateLabel.textColor = [SLFAppearance navBarTextColor];
    _stateLabel.textAlignment = UITextAlignmentRight;
    _stateLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
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
