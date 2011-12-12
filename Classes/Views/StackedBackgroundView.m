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
#import "StackedMenuViewController.h"

@interface StackedBackgroundView()
@property (nonatomic,retain) IBOutlet UIImageView *backgroundImageView;
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

- (void)dealloc {
    self.backgroundImageView = nil;
    [super dealloc];
}

- (void)configure {
    UIImage *bgImage = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
    _backgroundImageView = [[[UIImageView alloc] initWithImage:bgImage] retain];
    _backgroundImageView.origin = CGPointMake(-100,-60);
    [self addSubview:_backgroundImageView];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *imageFile = @"Default-Portrait~ipad";
    if (SLFIsLandscape())
        imageFile = @"Default-Landscape~ipad";
    UIImage *bgImage = [UIImage imageNamed:imageFile];
    _backgroundImageView.image = bgImage;
    _backgroundImageView.size = bgImage.size;
    _backgroundImageView.origin = CGPointMake(-100,-60);
}

@end
