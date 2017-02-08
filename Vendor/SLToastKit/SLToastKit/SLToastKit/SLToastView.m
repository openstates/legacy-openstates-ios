//
//  SLToastView.m
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import "SLToastView.h"
#import <QuartzCore/QuartzCore.h>
#import "SLTypeCheck.h"
#import "SLToastManager.h"
#import "SLToastObserver.h"

#ifndef MakeColorWithRGBA
    #define MakeColorWithRGBA(r,g,b,a) \
        [UIColor colorWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:a]
#endif

@interface SLToastView ()

@property (nonatomic, strong, nullable) SLToast *toast;
@property (nonatomic, assign) SLToastType toastType;
@property (nonatomic, strong) UIColor *gradientStartColor;
@property (nonatomic, strong) UIColor *gradientEndColor;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *thumbImage;
@property (nonatomic, strong) UIView *backgroundGradient;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *infoConstraints;

@property (nonatomic, assign, getter=isSuspended) BOOL suspended;

@end

@implementation SLToastView

+ (instancetype)showToastInView:(UIView *)parentView
                          toast:(SLToast *)toast
{
    if (!parentView || !toast)
        return nil;

    SLToastView *toastView = [self staticToastViewWithFrame:parentView.bounds toast:toast];
    if (!toastView)
        return nil;

    [parentView addSubview:toastView];

    NSTimeInterval duration = toast.duration;
    if (duration >= 0)
    {
        __weak SLToastView *wView = toastView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong SLToastView *sView = wView;
            if (!sView)
                return;
            if (!toast || ![sView.toast isEqual:toast] || toast.status == SLToastStatusFinished)
                return;  // The toast has changed since we posted it, so this execution won't fit the desired duration
            [sView hideInfoView];
        });
    }

    return toastView;
}

+ (instancetype)showToastInWindow:(UIWindow *)parentWindow
                   statusBarFrame:(CGRect)statusBarFrame
                         toast:(SLToast *)toast
{
    if (!parentWindow || !toast)
        return nil;

    CGRect viewFrame = CGRectInset(parentWindow.bounds, 0, CGRectGetHeight(statusBarFrame));
    SLToastView *toastView = [self staticToastViewWithFrame:viewFrame toast:toast];
    if (!toastView)
        return nil;
    toastView.statusBarFrame = statusBarFrame;

    [parentWindow addSubview:toastView];

    NSTimeInterval duration = toast.duration;
    if (duration >= 0)
    {
        __weak SLToastView *wView = toastView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong SLToastView *sView = wView;
            if (!sView)
                return;
            if (!toast || ![sView.toast isEqual:toast] || toast.status == SLToastStatusFinished)
                return;  // The toast has changed since we posted it, so this execution won't fit the desired duration
            [sView hideInfoView];
        });
    }

    return toastView;
}


- (BOOL)showToast:(SLToast *)toast
{
    UIView *parentView = self.superview;
    
    if (!parentView || !toast)
        return NO;
    
    self.toast = toast;
    toast.status = SLToastStatusShowing;

    NSTimeInterval duration = toast.duration;
    if (duration >= 0)
    {
        __weak SLToastView *wView = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong SLToastView *sView = wView;
            if (!sView)
                return;
            if (!toast || ![sView.toast isEqual:toast] || toast.status == SLToastStatusFinished)
                return;  // The toast has changed since we posted it, so this execution won't fit the desired duration
            [sView hideInfoView];
        });
    }

    return YES;
}

- (void)setToast:(SLToast *)toast
{
    _toast = toast;
    if (!toast)
        return;
    [self setType:toast.type title:toast.title subtitle:toast.subtitle image:toast.image];
}

+ (instancetype)staticToastViewWithFrame:(CGRect)frame toast:(SLToast *)toast
{
    SLToastView *toastView = [SLToastView toastViewWithFrame:frame toast:toast];
    return toastView;
}

+ (instancetype)staticToastViewWithFrame:(CGRect)frame
                                   type:(SLToastType)type
                                  title:(nullable NSString *)title
                               subtitle:(nullable NSString *)subtitle
                                  image:(nullable UIImage *)image
{
    NSString *compositeId = [NSString stringWithFormat:@"|type=%@|title=%@|subtitle=%@|", @(type),title,subtitle];
    SLToast *toast = [[SLToast alloc] initWithIdentifier:compositeId type:type title:title subtitle:subtitle image:image duration:-1];
    if (!toast)
        return nil;

    return [self toastViewWithFrame:frame toast:toast];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setup];
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    // update width of layers to allow rotation to landscape
    for (CALayer *layer in self.backgroundGradient.layer.sublayers)
    {
        if ([layer isKindOfClass:[CAGradientLayer class]])
        {
            CGRect layerFrame = layer.frame;
            layerFrame.size.width = CGRectGetWidth(frame);
            layer.frame = layerFrame;
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (void)setType:(SLToastType)type
          title:(NSString *)title
       subtitle:(NSString *)subtitle
          image:(UIImage *)image
{
    self.toastType = type;

    image = SLTypeImageOrNil(image);
    if (image)
        self.thumbImage.image = image;

    if (title || subtitle)
    {
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];

        title = [SLTypeStringOrNil(title) stringByTrimmingCharactersInSet:whitespace];
        self.titleLabel.text = SLTypeNonEmptyStringOrNil(title);

        subtitle = [SLTypeStringOrNil(subtitle) stringByTrimmingCharactersInSet:whitespace];
        self.detailLabel.text = SLTypeNonEmptyStringOrNil(subtitle);
    }

    [self invalidateIntrinsicContentSize];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];

    CGRect frame = self.frame;
    CGSize fittingSize = (CGSize){CGRectGetWidth(frame),UILayoutFittingCompressedSize.height};
    CGSize size = [self systemLayoutSizeFittingSize:fittingSize
                      withHorizontalFittingPriority:UILayoutPriorityRequired
                            verticalFittingPriority:UILayoutPriorityDefaultHigh + 50];
    frame.size = size;
    self.frame = frame;
}

- (void)setToastType:(SLToastType)toastType
{
    _toastType = toastType;

    UIColor *titleColor = [UIColor whiteColor];
    UIColor *startColor = nil;
    UIColor *endColor = nil;
    UIColor *detailColor = nil;
    UIImage *image = nil;

    switch (toastType) {
        case SLToastTypeActivity:
        {
            startColor = MakeColorWithRGBA(117,177,165,1.0);
            endColor = MakeColorWithRGBA(91,138,129,1.0);
            detailColor = MakeColorWithRGBA(245,245,237,1.0);
            titleColor = detailColor;
            _activityIndicator.color = detailColor;
            image = nil;
            break;
        }

        case SLToastTypeInfo:
        {
            startColor = MakeColorWithRGBA(117,177,165,1.0);
            endColor = MakeColorWithRGBA(91,138,129,1.0);
            detailColor = MakeColorWithRGBA(245,245,237,1.0);
            titleColor = detailColor;
            image = [self findGlyphNamed:@"glyph-note"];
            break;
        }

        case SLToastTypeNotice:
        {
            startColor = MakeColorWithRGBA(118, 119, 120, 1.0);
            endColor = MakeColorWithRGBA(63, 65, 67, 1.0);
            detailColor = MakeColorWithRGBA(210, 210, 235, 1.0);
            image = [self findGlyphNamed:@"glyph-note"];
            break;
        }

        case SLToastTypeSuccess:
        {
            startColor = MakeColorWithRGBA(127, 191, 34, 1.0);
            endColor = MakeColorWithRGBA(136, 159, 86, 1.0);
            detailColor = MakeColorWithRGBA(59, 69, 39, 1.0);
            image = [self findGlyphNamed:@"glyph-check"];
            break;
        }


        case SLToastTypeWarning:
        {
            startColor = MakeColorWithRGBA(253, 178, 77, 1.0);
            endColor = MakeColorWithRGBA(196, 123, 20, 1.0);
            detailColor = MakeColorWithRGBA(97, 61, 24, 1.0);
            image = [self findGlyphNamed:@"glyph-warning"];
            break;
        }

        case SLToastTypeError:
        default:
        {
            startColor = MakeColorWithRGBA(200, 36, 0, 1.0);
            endColor = MakeColorWithRGBA(150, 24, 0, 1.0);
            detailColor = MakeColorWithRGBA(255, 166, 166, 1.0);
            image = [self findGlyphNamed:@"glyph-warning"];
            break;
        }
    }

    image = SLTypeImageOrNil(image);
    _thumbImage.image = image;
    _thumbImage.hidden = (!image);

    _gradientStartColor = startColor;
    _gradientEndColor = endColor;

    _titleLabel.textColor = titleColor;
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];

    _detailLabel.textColor = detailColor;
    _detailLabel.font = [UIFont systemFontOfSize:14];

    if (toastType == SLToastTypeActivity)
        [_activityIndicator startAnimating];
    else
        [_activityIndicator stopAnimating];
}

- (UIImage *)findGlyphNamed:(NSString *)name
{
    if (!name)
        return nil;
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    if (!frameworkBundle || ![UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)])
        return [UIImage imageNamed:name];
    return [UIImage imageNamed:name inBundle:frameworkBundle compatibleWithTraitCollection:self.traitCollection];
}

- (void)setBackgroundGradientFrom:(UIColor *)fromColor to:(UIColor *)toColor
{
    if (!fromColor || !toColor)
        return;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGFloat lineHeight = 1.f;
    UIColor *lightColor = [self changeColor:fromColor withFactor:1.2];
    UIColor *darkColor = [self changeColor:toColor withFactor:0.25];

    UIView *gradientView = self.backgroundGradient;
    CGRect gradientRect = gradientView.bounds;
    CGFloat gradientWidth = CGRectGetWidth(gradientRect);
    CGFloat gradientHeight = CGRectGetHeight(gradientRect);
    gradient.frame = gradientRect;
    gradient.colors = @[(id)[fromColor CGColor], (id)[toColor CGColor]];

    CAGradientLayer *darkTopLine = [CAGradientLayer layer];
    darkTopLine.frame = CGRectMake(0, 0, gradientWidth, lineHeight);
    darkTopLine.colors = @[(id)[darkColor CGColor], (id)[darkColor CGColor]];

    CAGradientLayer *lightTopLine = [CAGradientLayer layer];
    lightTopLine.frame = CGRectMake(0, 1, gradientWidth, lineHeight);
    lightTopLine.colors = @[(id)[lightColor CGColor], (id)[lightColor CGColor]];

    CAGradientLayer *darkEndLine = [CAGradientLayer layer];
    darkEndLine.frame = CGRectMake(0, gradientHeight - lineHeight, gradientWidth, lineHeight);
    darkEndLine.colors = @[(id)[darkColor CGColor], (id)[darkColor CGColor]];

    NSArray *sublayers = [gradientView.layer.sublayers copy];
    for (CALayer *layer in sublayers)
    {
        [layer removeFromSuperlayer];
    }
    [gradientView.layer insertSublayer:gradient atIndex:0];
    [gradientView.layer insertSublayer:darkTopLine atIndex:1];
    [gradientView.layer insertSublayer:lightTopLine atIndex:2];
    [gradientView.layer insertSublayer:darkEndLine atIndex:3];
}

- (UIColor *)changeColor:(UIColor *)sourceColor withFactor:(CGFloat)factor
{
    /** oldComponents is the array INSIDE the original color.
     *  Changing these mutates the source color, so we copy it
     */
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([sourceColor CGColor]);
    size_t numComponents = CGColorGetNumberOfComponents([sourceColor CGColor]);
    CGFloat newComponents[4] = {0.f,0.f,0.f,0.f};

    switch (numComponents) {
        case 2: {
            //grayscale
            newComponents[0] = oldComponents[0]*factor;
            newComponents[1] = oldComponents[0]*factor;
            newComponents[2] = oldComponents[0]*factor;
            newComponents[3] = oldComponents[1];
            break;
        }

        case 4: {
            //RGBA
            newComponents[0] = oldComponents[0]*factor;
            newComponents[1] = oldComponents[1]*factor;
            newComponents[2] = oldComponents[2]*factor;
            newComponents[3] = oldComponents[3];
            break;
        }
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);

    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);

    return retColor;
}

- (void)hideInfoView
{
    SLToastManager *manager = self.toastManager;
    if (manager && !self.isSuspended)
    {
        SLToast *nextToast = [manager pullNext];
        if (nextToast)
        {
            if (self.toast && ![self.toast isEqual:nextToast])
            {
                self.toast.status = SLToastStatusFinished;
            }
            [self showToast:nextToast];
            return;
        }
    }

    NSTimeInterval duration = 0.25;
    CGRect oldRect = self.frame;
    CGRect newRect = oldRect;
    newRect.origin =  CGPointMake(0,-CGRectGetHeight(oldRect));

    UIViewAnimationOptions options = (UIViewAnimationOptionCurveEaseInOut |
                                      UIViewAnimationOptionLayoutSubviews |
                                      UIViewAnimationOptionAllowAnimatedContent |
                                      UIViewAnimationOptionShowHideTransitionViews);

    __weak typeof(self) wSelf = self;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf)
            return;
        sSelf.frame = newRect;
    } completion:^(BOOL finished) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf)
            return;
        [sSelf finish];
    }];
}

- (void)finish
{
    SLToastStatus status = SLToastStatusFinished;
    SLToast *toast = self.toast;
    if (toast)
        toast.status = status;

    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SLToastManager *toastMgr = self.toastManager;
    if (toastMgr
        && [toastMgr conformsToProtocol:@protocol(SLToastObserver)]
        && [toastMgr respondsToSelector:@selector(userDismissedToast:)])
    {
        [(id<SLToastObserver>)toastMgr userDismissedToast:self.toast];
    }
    
#if SLToast_Use_Nag_Limiter == 1
    self.suspended = YES;
#endif
    
    [self hideInfoView];
    
#if SLToast_Use_Nag_Limiter == 1
    if (self.isSuspended)
        self.suspended = NO;
#endif
    
}

+ (instancetype)toastViewWithFrame:(CGRect)frame toast:(SLToast *)toast;
{
    SLToastView *toastView =  [[SLToastView alloc] initWithFrame:frame];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromBottom;
    [toastView.layer addAnimation:transition forKey:nil];

    if (toast)
    {
        toastView.toast = toast;

        CGSize fittingSize = (CGSize){CGRectGetWidth(frame),UILayoutFittingCompressedSize.height};
        CGSize size = [toastView systemLayoutSizeFittingSize:fittingSize
                              withHorizontalFittingPriority:UILayoutPriorityRequired
                                    verticalFittingPriority:UILayoutPriorityDefaultHigh + 50];
        frame.size = size;
        toastView.frame = frame;
    }

    return toastView;
}

- (void)updateConstraints
{
    [super updateConstraints];
    if (_infoConstraints.count)
        [NSLayoutConstraint deactivateConstraints:_infoConstraints];

    [self setContentHuggingPriority:900 forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:900 forAxis:UILayoutConstraintAxisVertical];

    NSMutableArray<NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] init];

    NSLayoutConstraint *constraint = nil;
    NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
    NSString *constraintGroupID = nil;

    constraintGroupID = @"SLToastView-MinSize";
    {
        attribute = NSLayoutAttributeHeight;
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute
                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                     toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1 constant:50];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];
    }

    constraintGroupID = @"SLToastView-Background";
    {
        NSArray *attributes = @[@(NSLayoutAttributeTop),
                                @(NSLayoutAttributeLeading),
                                @(NSLayoutAttributeBottom),
                                @(NSLayoutAttributeTrailing)];

        for (NSNumber *attributeValue in attributes)
        {
            attribute = [attributeValue integerValue];
            constraint = [NSLayoutConstraint constraintWithItem:_backgroundGradient attribute:attribute
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self attribute:attribute
                                                     multiplier:1 constant:0];
            constraint.identifier = constraintGroupID;
            [constraints addObject:constraint];
        }
    }

    UIEdgeInsets marginInsets = UIEdgeInsetsMake(6, 10, 6, 10);

    constraintGroupID = @"SLToastView-Image";
    {
        attribute = NSLayoutAttributeLeading;
        constraint = [NSLayoutConstraint constraintWithItem:_thumbImage attribute:attribute
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self attribute:attribute
                                                 multiplier:1 constant:marginInsets.left];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        attribute = NSLayoutAttributeCenterY;
        constraint = [NSLayoutConstraint constraintWithItem:_thumbImage attribute:attribute
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self attribute:attribute
                                                 multiplier:1 constant:0];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        attribute = NSLayoutAttributeWidth;
        constraint = [NSLayoutConstraint constraintWithItem:_thumbImage attribute:attribute
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1 constant:37];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        attribute = NSLayoutAttributeHeight;
        constraint = [NSLayoutConstraint constraintWithItem:_thumbImage attribute:attribute
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1 constant:37];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];
    }

    constraintGroupID = @"SLToastView-Activity";
    {
        attribute = NSLayoutAttributeCenterY;
        constraint = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:attribute
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_thumbImage attribute:attribute
                                                 multiplier:1 constant:0];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        attribute = NSLayoutAttributeCenterX;
        constraint = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:attribute
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_thumbImage attribute:attribute
                                                 multiplier:1 constant:0];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];
    }

    constraintGroupID = @"SLToastView-Title";
    {
        constraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_thumbImage attribute:NSLayoutAttributeTrailing
                                                 multiplier:1 constant:marginInsets.left];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self attribute:NSLayoutAttributeTrailing
                                                 multiplier:1 constant:-(marginInsets.right)];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self attribute:NSLayoutAttributeTop
                                                 multiplier:1 constant:marginInsets.top];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];
    }

    constraintGroupID = @"SLToastView-Subtitle";
    {
        constraint = [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_thumbImage attribute:NSLayoutAttributeTrailing
                                                 multiplier:1 constant:marginInsets.left];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self attribute:NSLayoutAttributeTrailing
                                                 multiplier:1 constant:-(marginInsets.right)];
        constraint.identifier = constraintGroupID;
        [constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_titleLabel attribute:NSLayoutAttributeBottom
                                                 multiplier:1 constant:marginInsets.top];
        constraint.identifier = constraintGroupID;
        constraint.priority = UILayoutPriorityRequired;
        [constraints addObject:constraint];

        constraint = [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self attribute:NSLayoutAttributeBottom
                                                 multiplier:1 constant:-(marginInsets.bottom)];
        constraint.identifier = constraintGroupID;
        constraint.priority = UILayoutPriorityRequired;
        [constraints addObject:constraint];
    }

    _infoConstraints = constraints;
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.detailLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailLabel.frame);

    [self setBackgroundGradientFrom:self.gradientStartColor to:self.gradientEndColor];
}

- (void)setup
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.opaque = NO;
    self.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowOpacity = 0.7;

    CGRect bounds = self.bounds;
    if (!_backgroundGradient || !_backgroundGradient.superview)
    {
        _backgroundGradient = [[UIView alloc] initWithFrame:bounds];
        _backgroundGradient.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundGradient.alpha = 0.88f;
        [self addSubview:_backgroundGradient];
    }

    if (!_titleLabel || !_titleLabel.superview)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.layer.shadowOffset = CGSizeMake(0.f, -1.f);
        _titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _titleLabel.layer.shadowRadius = 1.f;
        _titleLabel.layer.shadowOpacity = 0.7;
        [_titleLabel setContentHuggingPriority:900 forAxis:UILayoutConstraintAxisVertical];
        [_titleLabel setContentCompressionResistancePriority:920 forAxis:UILayoutConstraintAxisVertical];

        [self addSubview:_titleLabel];
    }

    if (!_detailLabel || !_detailLabel.superview)
    {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.numberOfLines = 3;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_detailLabel setContentHuggingPriority:910 forAxis:UILayoutConstraintAxisVertical];
        [_detailLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired - 10) forAxis:UILayoutConstraintAxisVertical];
        [self addSubview:_detailLabel];
    }

    if (!_thumbImage || !_thumbImage.superview)
    {
        _thumbImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thumbImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_thumbImage];
    }

    if (!_activityIndicator || !_activityIndicator.superview)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.layer.shadowOffset = CGSizeMake(0.f, -1.f);
        _activityIndicator.layer.shadowColor = [UIColor blackColor].CGColor;
        _activityIndicator.layer.shadowRadius = 1.f;
        _activityIndicator.layer.shadowOpacity = 0.7;
        [self addSubview:_activityIndicator];
    }

    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

@end
