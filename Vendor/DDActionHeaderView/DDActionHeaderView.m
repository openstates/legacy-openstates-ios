//
//  DDActionHeaderView.m
//  Heavily modified by Greg Combs
//
//  DDActionHeaderView (Released under MIT License)
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
#import <QuartzCore/QuartzCore.h>

@interface DDActionHeaderView ()
@property(nonatomic, retain) UIView *actionPickerView;
@property(nonatomic, retain) CAGradientLayer *actionPickerGradientLayer;
- (void)handleActionPickerViewTap:(UIGestureRecognizer *)gestureRecognizer;
@end

@implementation DDActionHeaderView

@synthesize items = items_;
@synthesize actionPickerView = actionPickerView_;
@synthesize actionPickerGradientLayer = actionPickerGradientLayer_;

#pragma mark -
#pragma mark View lifecycle

- (void)setup {	
    [super setup];
	actionPickerView_ = [[UIView alloc] initWithFrame:CGRectZero];
	actionPickerView_.layer.cornerRadius = 15;
	actionPickerView_.layer.borderWidth = 1.5;
	actionPickerView_.layer.borderColor = [UIColor darkGrayColor].CGColor;
	actionPickerView_.clipsToBounds = YES;
	
	actionPickerGradientLayer_ = [[CAGradientLayer layer] retain];
	actionPickerGradientLayer_.anchorPoint = CGPointZero;
	actionPickerGradientLayer_.position = CGPointZero;
	actionPickerGradientLayer_.startPoint = CGPointZero;
	actionPickerGradientLayer_.endPoint = CGPointMake(0, 1);
	actionPickerGradientLayer_.colors = [NSArray arrayWithObjects:(id)[UIColor grayColor].CGColor, (id)[UIColor darkGrayColor].CGColor, nil];
	[actionPickerView_.layer addSublayer:actionPickerGradientLayer_];
	[self addSubview:actionPickerView_];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionPickerViewTap:)];
	tapGesture.delegate = self;
	[actionPickerView_ addGestureRecognizer:tapGesture];
	[tapGesture release];	
}

- (void)dealloc {
    self.items = nil;
    self.actionPickerView = nil;
    self.actionPickerGradientLayer = nil;
    [super dealloc];
}

static const CGFloat closedWidth = 60;
static const CGFloat pickerHeight = 50;

- (void)layoutSubviews {
    const CGFloat offset = 10;
    const CGFloat twoOffsets = offset * 2;
    const CGFloat halfOffset = offset / 2;
    self.titleLabel.frame = CGRectMake(offset, offset, self.frame.size.width - (closedWidth+twoOffsets), (pickerHeight - halfOffset));
    self.actionPickerGradientLayer.bounds = CGRectMake(0, 0, self.frame.size.width, pickerHeight);
	if (CGRectIsEmpty(self.actionPickerView.frame)) {
		self.actionPickerView.frame = CGRectMake(self.frame.size.width - (closedWidth+halfOffset), 7, closedWidth, pickerHeight);        		
	} else {
		__block __typeof__(self) blockSelf = self;
		[UIView animateWithDuration:0.2 animations:^ {
            if (blockSelf.titleLabel.isHidden) {
                blockSelf.actionPickerView.frame = CGRectMake(offset, 7, blockSelf.frame.size.width - (twoOffsets-halfOffset), pickerHeight);
            } else {
                blockSelf.actionPickerView.frame = CGRectMake(blockSelf.frame.size.width - (closedWidth+halfOffset), 7, closedWidth, pickerHeight);        
            }
        }];		
	}
}

- (void)shrinkActionPicker {
    self.titleLabel.hidden = NO;
    [self setNeedsLayout];
}

- (BOOL)isActionPickerExpanded {
	return (self.titleLabel.isHidden && self.actionPickerView.bounds.size.width != closedWidth);
}

- (void)setItems:(NSArray *)newItems {
    if (items_ == newItems)
        return;
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
