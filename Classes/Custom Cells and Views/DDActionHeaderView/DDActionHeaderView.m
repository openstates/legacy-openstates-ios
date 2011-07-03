//
//  DDActionHeaderView.m
//  DDActionHeaderView (Released under MIT License)
//
//  Created by digdog on 10/5/10.
//  Copyright (c) 2010 Ching-Lan 'digdog' HUANG.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "DDActionHeaderView.h"
#import "TexLegeTheme.h"
//#import "UIView+JMNoise.h"

@interface DDActionHeaderView ()
@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UIView *actionPickerView;
@property(nonatomic, retain) CAGradientLayer *actionPickerGradientLayer;

- (void)setup;
- (void)drawLinearGradientInRect:(CGRect)rect colors:(CGFloat[])colours;
- (void)drawLineInRect:(CGRect)rect colors:(CGFloat[])colors;
- (void)handleActionPickerViewTap:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation DDActionHeaderView

@synthesize borderGradientHidden = borderGradientHidden_;
@synthesize titleLabel = titleLabel_;
@synthesize items = items_;
@synthesize actionPickerView = actionPickerView_;
@synthesize actionPickerGradientLayer = actionPickerGradientLayer_;

#pragma mark -
#pragma mark View lifecycle

// For creating programmatically
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 70.0f)])) {
		[self setup];		
	}
	return self;
}

// For using in IB
- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
		[self setup];
    }
    return self;
} 

- (void)setup {
	self.opaque = NO;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	titleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel_.font = [TexLegeTheme boldEighteen];
	titleLabel_.numberOfLines = 0;        
	titleLabel_.backgroundColor = [UIColor clearColor];
	titleLabel_.textColor = [TexLegeTheme textDark];
	titleLabel_.shadowColor = [UIColor whiteColor];
	titleLabel_.shadowOffset = CGSizeMake(0.0f, 1.0f);
	titleLabel_.hidden = NO;
	titleLabel_.opaque = NO;
	[self addSubview:titleLabel_];
	
	actionPickerView_ = [[UIView alloc] initWithFrame:CGRectZero];
	actionPickerView_.layer.cornerRadius = 25.0f;
	actionPickerView_.layer.borderWidth = 1.0f;
	actionPickerView_.layer.borderColor = [UIColor darkGrayColor].CGColor;
	actionPickerView_.clipsToBounds = YES;
	
	actionPickerGradientLayer_ = [[CAGradientLayer layer] retain];
	actionPickerGradientLayer_.anchorPoint = CGPointMake(0.0f, 0.0f);
	actionPickerGradientLayer_.position = CGPointMake(0.0f, 0.0f);
	actionPickerGradientLayer_.startPoint = CGPointZero;
	actionPickerGradientLayer_.endPoint = CGPointMake(0.0f, 1.0f);
	actionPickerGradientLayer_.colors = [NSArray arrayWithObjects:(id)[UIColor grayColor].CGColor, (id)[UIColor darkGrayColor].CGColor, nil];
	[actionPickerView_.layer addSublayer:actionPickerGradientLayer_];
	
	[self addSubview:actionPickerView_];
	
#if 0
	// We're turning this off for now, we don't need the extended action menu, yet.
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionPickerViewTap:)];
	tapGesture.delegate = self;
	[actionPickerView_ addGestureRecognizer:tapGesture];
	[tapGesture release];
#endif		
	borderGradientHidden_ = NO;	
	
}

- (void)dealloc {
    nice_release(titleLabel_);
    nice_release(items_);
    nice_release(actionPickerView_);
    nice_release(actionPickerGradientLayer_);
    
    [super dealloc];
}

#pragma mark Layout & Redraw

- (void)layoutSubviews {
    
    self.titleLabel.frame = CGRectMake(12.0f, 10.0f, self.frame.size.width - 70.0f, 45.0f);
    self.actionPickerGradientLayer.bounds = CGRectMake(0.0f, 0.0f, self.frame.size.width - 20.0f, 50.0f);
    
	if (CGRectIsEmpty(self.actionPickerView.frame)) {
		self.actionPickerView.frame = CGRectMake(self.frame.size.width - 60.0f, 7.0f, 50.0f, 50.0f);        		
	} else {
		__block __typeof__(self) blockSelf = self;
		[UIView animateWithDuration:0.2 
						 animations:^{
							 if (blockSelf.titleLabel.isHidden) {
								 blockSelf.actionPickerView.frame = CGRectMake(10.0f, 7.0f, blockSelf.frame.size.width - 20.0f, 50.0f);
							 } else {
								 blockSelf.actionPickerView.frame = CGRectMake(blockSelf.frame.size.width - 60.0f, 7.0f, 50.0f, 50.0f);        
							 }
						 }];		
	}
}

- (void)drawRect:(CGRect)rect {	

	CGFloat colors[] = {
		200.0f / 255.0f, 207.0f / 255.0f, 212.0f / 255.0f, 1.0f,
        169.0f / 255.0f, 178.0f / 255.0f, 185.0f / 255.0f, 1.0f
	};	
	[self drawLinearGradientInRect:CGRectMake(0.0f, 0.0f, rect.size.width, 64.0f) colors:colors];

    if (!self.borderGradientHidden) {
        CGFloat colors2[] = {
            152.0f / 255.0f, 156.0f / 255.0f, 161.0f / 255.0f, 0.5f,
            152.0f / 255.0f, 156.0f / 255.0f, 161.0f / 255.0f, 0.1f
        };
        [self drawLinearGradientInRect:CGRectMake(0.0f, 65.0f, rect.size.width, 5.0f) colors:colors2];		
    }
        
    CGFloat line1[]={240.0f / 255.0f, 230.0f / 255.0f, 230.0f / 255.0f, 1.0f};
    [self drawLineInRect:CGRectMake(0.0f, 0.0f, rect.size.width, 0.0f) colors:line1];
    
    CGFloat line2[]={94.0f / 255.0f,  103.0f / 255.0f, 109.0f / 255.0f, 1.0f};
    [self drawLineInRect:CGRectMake(0.0f, 64.5f, rect.size.width, 0.0f) colors:line2];      
	
	//[self drawCGNoiseWithOpacity:0.08f];
}

#pragma mark Drawing private methods

- (void)drawLinearGradientInRect:(CGRect)rect colors:(CGFloat[])colours {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colours, NULL, 2);
	CGColorSpaceRelease(rgb);
	CGPoint start, end;
	
	start = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height * 0.25);
	end = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height * 0.75);;
	
	CGContextClipToRect(context, rect);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);
}

- (void)drawLineInRect:(CGRect)rect colors:(CGFloat[])colors {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGContextSetRGBStrokeColor(context, colors[0], colors[1], colors[2], colors[3]);
	CGContextSetLineCap(context, kCGLineCapButt);
	CGContextSetLineWidth(context, 1.0f);
	
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	CGContextStrokePath(context);
	
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Public method

- (void)shrinkActionPicker {
    self.titleLabel.hidden = NO;
    [self setNeedsLayout];
}

#pragma mark Accessors

- (void)setBorderGradientHidden:(BOOL)newBorderGradientHidden {
    borderGradientHidden_ = newBorderGradientHidden;
    [self setNeedsDisplay];
}

- (BOOL)isActionPickerExpanded {
	return (self.titleLabel.isHidden && self.actionPickerView.bounds.size.width != 50.0f);
}

- (void)setItems:(NSArray *)newItems {
    if (items_ != newItems) {
        for (UIView *subview in self.actionPickerView.subviews) {
            [subview removeFromSuperview];
        }
        
        [items_ release];
        items_ = [newItems copy];
        
        for (id item in items_) {
			if ([item isKindOfClass:[UIView class]]) {
				[self.actionPickerView addSubview:item];
			}
        }
    }
}

#pragma mark -
#pragma mark UITapGestureRecognizer & UIGestureRecognizerDelegate

- (void)handleActionPickerViewTap:(UIGestureRecognizer *)gestureRecognizer {
    self.titleLabel.hidden = !self.titleLabel.isHidden;
    [self setNeedsLayout];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    for (UIView *subview in self.actionPickerView.subviews) {
        if (subview == touch.view && self.titleLabel.isHidden) {
            return NO;
        }
    }
        
    return YES;
}

@end
