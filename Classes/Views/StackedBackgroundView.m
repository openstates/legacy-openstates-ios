//
//  StackedBackgroundView.m
//  Created by Greg Combs on 11/15/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StackedBackgroundView.h"
#import "StackedMenuViewController.h"

@interface StackedBackgroundView()
@property (nonatomic,strong) IBOutlet UIImageView *backgroundImageView;
- (void)configure;
@end

@implementation StackedBackgroundView
@synthesize backgroundImageView = _backgroundImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.autoresizesSubviews = YES;
        self.opaque = YES;
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


- (void)configure {
    UIImage *bgImage = [UIImage imageNamed:@"StackedBackground-Portrait"];
    _backgroundImageView = [[UIImageView alloc] initWithImage:bgImage];
    [self addSubview:_backgroundImageView];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *imageFile = @"StackedBackground-Portrait";
    if (SLFIsLandscape())
        imageFile = @"StackedBackground-Landscape";
    UIImage *bgImage = [UIImage imageNamed:imageFile];
    _backgroundImageView.image = bgImage;
    _backgroundImageView.size = bgImage.size;
}

@end
