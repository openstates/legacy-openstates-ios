//
//  BillStageStackPanel.m
//  Stacks UIView's horizontally or vertically with a specified spacing. 
//  If contained in a UIScrollView, it can automatically adjust it's content size.
//
//  Created by Raymond Reggers on 8/5/10.
//  Copyright 2010 Adaptiv Design. All rights reserved.
//
// http://www.adaptiv.nl/blog/single/stacking-uiviews-uikit/
 /*
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3f];
			self.segmentControl.alpha = 1.0f;
			[UIView commitAnimations];

  
  - (void)viewDidLoad {
  [super viewDidLoad];
  
  self.myStackPanel.resizeFrame = YES;
  self.myStackPanel.spacing = 8;
  }
*/

#import "BillStageStackPanel.h"
 
#pragma mark -
#pragma mark IMPLEMENT
 
@implementation BillStageStackPanel
@synthesize orientation, spacing, resizeFrame;
 
 
#pragma mark -
#pragma mark UIView initialization
 
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        [self setNeedsLayout];
    }
     
    return self;
}
 
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
        [self setNeedsLayout];
    }
     
    return self;
}
 
 
#pragma mark -
#pragma mark Property setters/getters
 
- (void)_orientationSetter:(StackOrientation)newValue {
    orientation = newValue;
    [self setNeedsLayout];
}
 
- (void)_spacingSetter:(int)newValue {
    spacing = newValue;
    [self setNeedsLayout];
}
 
- (void)_resizeFrameSetter:(BOOL)newValue {
    resizeFrame = newValue;
    [self setNeedsLayout];
}
 
 
#pragma mark -
#pragma mark UIView overrides
 
- (void)layoutSubviews {
    int offset = 0;
     
    for(UIView *child in self.subviews) {
        CGPoint point = child.frame.origin;
         
        if(self.orientation == VERTICAL) {
            point.y = offset;
        } else {
            point.x = offset;
        }
         
        CGRect rect = child.frame;
        rect.origin = point;
        child.frame = rect;
         
        if(self.orientation == VERTICAL)offset += child.frame.size.height;
        else offset += child.frame.size.width;
         
        offset += self.spacing;
    }
     
    if([self.subviews count] > 0) offset -= self.spacing;
    if(self.resizeFrame) {
        CGRect rect = self.frame;
        CGSize size = rect.size;
         
        if(self.orientation == VERTICAL) size.height = offset;
        else size.width = offset;
         
        rect.size = size;
        if(self.frame.size.width != rect.size.width || self.frame.size.height != rect.size.height)
        {
            self.frame = rect;
            if(self.superview != nil){
                [self.superview setNeedsLayout];
                if([self.superview isKindOfClass:[UIScrollView class]]) {
                    ((UIScrollView *)self.superview).contentSize = size;
                }
            }
        }
    }
     
    [super layoutSubviews];
}
 
 
#pragma mark -
#pragma mark Memory management
 
- (void)dealloc {
    [super dealloc];
}
 
 
@end