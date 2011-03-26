//
//  S7GraphView.m
//  S7Touch
//
//  Created by Aleks Nesterow on 9/27/09.
//  aleks.nesterow@gmail.com
//  
//  Thanks to http://snobit.habrahabr.ru/ for releasing sources for his
//  Cocoa component named GraphView.
//  
//  Copyright © 2009, 7touchGroup, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of the 7touchGroup, Inc. nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY 7touchGroup, Inc. "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL 7touchGroup, Inc. BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  

#import "S7GraphView.h"
#import "TexLegeTheme.h"
#import <QuartzCore/QuartzCore.h>

@interface S7GraphView (PrivateMethods)

- (void)initializeComponent;

@end

@implementation S7GraphView

+ (UIColor *)colorByIndex:(NSInteger)index {
	
	UIColor *color;
	
	switch (index) {
		case 0: color = RGB(5, 141, 191);
			break;
		case 1: color = RGB(80, 180, 50);
			break;		
		case 2: color = RGB(255, 102, 0);
			break;
		case 3: color = RGB(255, 158, 1);
			break;
		case 4: color = RGB(252, 210, 2);
			break;
		case 5: color = RGB(248, 255, 1);
			break;
		case 6: color = RGB(176, 222, 9);
			break;
		case 7: color = RGB(106, 249, 196);
			break;
		case 8: color = RGB(178, 222, 255);
			break;
		case 9: color = RGB(4, 210, 21);
			break;
		default: color = RGB(204, 204, 204);
			break;
	}
	
	return color;
}

@synthesize dataSource = _dataSource, xValuesFormatter = _xValuesFormatter, yValuesFormatter = _yValuesFormatter;
@synthesize drawAxisX = _drawAxisX, drawAxisY = _drawAxisY, drawGridX = _drawGridX, drawGridY = _drawGridY;
@synthesize highlightColor = _highlightColor;
@synthesize xValuesColor = _xValuesColor, yValuesColor = _yValuesColor, gridXColor = _gridXColor, gridYColor = _gridYColor;
@synthesize drawInfo = _drawInfo, info = _info, infoColor = _infoColor;
@synthesize xUnit = _xUnit, yUnit = _yUnit;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
	
    if (self = [super initWithFrame:frame]) {
		[self initializeComponent];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	
	if (self = [super initWithCoder:decoder]) {
		[self initializeComponent];
	}
	
	return self;
}

- (void)dealloc {
	
	[_xValuesFormatter release];
	[_yValuesFormatter release];
	
	[_xValuesColor release];
	[_yValuesColor release];
	
	[_gridXColor release];
	[_gridYColor release];
	
	[_info release];
	[_infoColor release];
    
    [_xUnit release];
    [_yUnit release];
	
	[_highlightColor release];
	[super dealloc];
}

- (void)setPathToRoundedRect:(CGRect)rect forInset:(NSUInteger)inset inContext:(CGContextRef)context
{
	// Experimentally determined
	static NSUInteger cornerRadius = 5;
	
	// Unpack size for compactness, find minimum dimension
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	CGFloat m = w<h?w:h;
	
	// Bounds
	CGFloat b = rect.origin.y;
	CGFloat t = b + h;
	CGFloat l = rect.origin.x;
	CGFloat r = l + w;
	CGFloat d = (inset<cornerRadius)?(cornerRadius-inset):0;
	
	// Special case: Degenerate rectangles abort this method
	if (m <= 0) return;
	
	// Limit radius to 1/2 of the rectangle's shortest axis
	d = (d>0.5*m)?(0.5*m):d;
	
	// Define a CW path in the CG co-ordinate system (origin at LL)
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, (l+r)/2, t);		// Begin at TDC
	CGContextAddArcToPoint(context, r, t, r, b, d);	// UR corner
	CGContextAddArcToPoint(context, r, b, l, b, d);	// LR corner
	CGContextAddArcToPoint(context, l, b, l, t, d);	// LL corner
	CGContextAddArcToPoint(context, l, t, r, t, d);	// UL corner
	CGContextClosePath(context);					// End at TDC
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	// Add clipping path
	// * Runs around the perimeter of the included area
	// * Dimensions are *not* (further) reduced, as path is a zero-thickness boundary
	// * A path is created "forInset" 1:
	//   . When one rounded corner is placed inside another, the interior
	//     corner must have its radius reduced for a proper appearance
	//rect = CGRectMake(rect.origin.x, rect.origin.y, 
	//							 rect.size.width-2, rect.size.height-2);
	
	//[self setPathToRoundedRect:rect forInset:1 inContext:c];
	CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
	CGContextFillRect(c, rect);
	//CGContextClip(c);
	
	NSUInteger numberOfPlots = [self.dataSource graphViewNumberOfPlots:self];
	
	if (!numberOfPlots) {
		return;
	}
	
	CGFloat offsetX = _drawAxisY ? 60.0f : 10.0f;
	CGFloat offsetY = (_drawAxisX || _drawInfo) ? 30.0f : 10.0f;
	
	CGFloat minY = 0.0;
	CGFloat maxY = 0.0;
	
	UIFont *font = [TexLegeTheme boldTen];
	
	minY = -1.5f;
	maxY = 1.5f;

	NSInteger numSteps = 6;
	CGFloat step = (maxY - minY) / numSteps;	// five vertical lines / steps
	CGFloat stepY = (rect.size.height - (offsetY * 2)) / (maxY - minY);
    
	CGFloat value = minY - step;
	for (NSUInteger i = 0; i <= numSteps; i++) {
        NSInteger y = (i * step) * stepY;
		value = value + step;
		
		if (_drawGridY) {
			
			CGFloat lineDash[2];
			lineDash[0] = 3.0f;
			lineDash[1] = 3.0f;
			
			CGContextSetLineDash(c, 0.0f, lineDash, 2);
			CGContextSetLineWidth(c, 0.1f);
			
			CGPoint startPoint = CGPointMake(offsetX, rect.size.height - y - offsetY);
			CGPoint endPoint = CGPointMake(rect.size.width - offsetX, rect.size.height - y - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, self.gridYColor.CGColor);
			CGContextStrokePath(c);
		}
		
		if (i >= 0 && _drawAxisY) {
			
			NSNumber *valueToFormat = [NSNumber numberWithFloat:value];
			NSString *valueString;
			
			if (_yValuesFormatter) {
				valueString = [_yValuesFormatter stringForObjectValue:valueToFormat];
			} else {
				valueString = [valueToFormat stringValue];
			}
			
			[self.yValuesColor set];
			CGRect valueStringRect = CGRectMake(0.0f, rect.size.height - y - offsetY, 50.0f, 20.0f);
			
			[valueString drawInRect:valueStringRect withFont:font
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
            
            //Add unit-y.
            if (i == numSteps) {
                if (_yUnit) {
					//CGRect textRect = CGRectMake(0.f, self.frame.size.height/2.f/*self.frame.size.height - y - offsetY - 15.0f*/, 20.0f, 90.0f);
					
					CGContextRef theContext = UIGraphicsGetCurrentContext();
					CGContextSaveGState(theContext);//create the path using our points array
					
					CGContextTranslateCTM(theContext, 0, rect.size.height);
					CGContextScaleCTM(theContext, 1, -1);

					CGAffineTransform myTextTransform; // 2
					CGContextSelectFont (theContext, "HelveticaNeue-Bold", 10, kCGEncodingMacRoman);
					CGContextSetCharacterSpacing (theContext, 1); // 4
					CGContextSetTextDrawingMode (theContext, kCGTextFillStroke); // 5
					CGContextSetFillColorWithColor (theContext, self.yValuesColor.CGColor);
					myTextTransform =  CGAffineTransformMakeRotation  (90.f*(M_PI / 180.f));
					CGContextSetTextMatrix (theContext, myTextTransform); // 9
					const char *titleString = [self.yUnit UTF8String];
					
					CGContextShowTextAtPoint (theContext, 20.f, (rect.size.height/2) - 35.f, 
											  titleString, [self.yUnit length]); // 10
					CGContextRestoreGState(theContext);//create the path using our points array

                   // [_yUnit drawInRect:textRect withFont:font
				   //    lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
                }
            }
		}
	}
	
	
	NSUInteger maxStep;
	
	NSArray *xValues = [self.dataSource graphViewXValues:self];
	NSUInteger xValuesCount = xValues.count;
    
	if (xValuesCount > [self.dataSource graphViewMaximumNumberOfXaxisValues:self]) {
		
		NSUInteger stepCount = [self.dataSource graphViewMaximumNumberOfXaxisValues:self];
		NSUInteger count = xValuesCount - 1;
		
		for (NSUInteger i = 4; i < 8; i++) {
			if (count % i == 0) {
				stepCount = i;
			}
		}
		
		step = xValuesCount / stepCount;
		maxStep = stepCount + 1;
		
	} else {
		
		step = 1;
		maxStep = xValuesCount;
	}
	
	CGFloat stepX = (rect.size.width - (offsetX * 2)) / (xValuesCount - 1);
	
	for (NSUInteger i = 0; i < maxStep; i++) {
		
		NSUInteger x = (i * step) * stepX;
		
		if (x > rect.size.width - (offsetX * 2)) {
			x = rect.size.width - (offsetX * 2);
		}
		
		NSUInteger index = i * step;
		
		if (index >= xValuesCount) {
			index = xValuesCount - 1;
		}
		
		if (_drawGridX) {
			
			CGFloat lineDash[2];
			
			lineDash[0] = 3.0f;
			lineDash[1] = 3.0f;
			
			CGContextSetLineDash(c, 0.0f, lineDash, 2);
			CGContextSetLineWidth(c, 0.1f);
			
			CGPoint startPoint = CGPointMake(x + offsetX, offsetY);
			CGPoint endPoint = CGPointMake(x + offsetX, rect.size.height - offsetY);
			
			CGContextMoveToPoint(c, startPoint.x, startPoint.y);
			CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
			CGContextClosePath(c);
			
			CGContextSetStrokeColorWithColor(c, self.gridXColor.CGColor);
			CGContextStrokePath(c);
		}
		
		if (_drawAxisX) {
			
			id valueToFormat = [xValues objectAtIndex:index];
			NSString *valueString;
			
			if (_xValuesFormatter) {
                valueString = [_xValuesFormatter stringForObjectValue:valueToFormat];
			} else {
				valueString = [NSString stringWithFormat:@"%@", valueToFormat];
			}
			
			[self.xValuesColor set];
			[valueString drawInRect:CGRectMake(x, rect.size.height - 20.0f, 120.0f, 20.0f) withFont:font
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
            
            //Add a button which has clear background.
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x+50, offsetY, 20.0f, rect.size.height-offsetY)];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setTag:i];
            [button addTarget:self action:@selector(xAxisWasTapped:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
            [button release];
            
            //Add unit-x.
            if (i == maxStep-1) {
                if (_xUnit) {
                    [_xUnit drawInRect:CGRectMake(x+25, rect.size.height - 20.0f, 120.0f, 20.0f) withFont:font
                              lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
                }
            }
		}
	}
	
	stepX = (rect.size.width - (offsetX * 2)) / (xValuesCount - 1);
	
	CGContextSetLineDash(c, 0, NULL, 0);
	
	for (NSUInteger plotIndex = 0; plotIndex < numberOfPlots; plotIndex++) {
		
		NSArray *values = [self.dataSource graphView:self yValuesForPlot:plotIndex];
		BOOL shouldFill = NO;
		
		if ([self.dataSource respondsToSelector:@selector(graphView:shouldFillPlot:)]) {
			shouldFill = [self.dataSource graphView:self shouldFillPlot:plotIndex];
		}
		
		CGColorRef plotColor;
		if ([self.dataSource respondsToSelector:@selector(graphView:colorForPlot:)])
			plotColor = [self.dataSource graphView:self colorForPlot:plotIndex].CGColor;
		else
			plotColor = [S7GraphView colorByIndex:plotIndex].CGColor;
        int numberDataCount = 0;
        for (NSUInteger valueIndex = 0; valueIndex < values.count; valueIndex++) {
            if ([@"NSCFNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex] class])] 
				|| [@"NSNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex] class])]) {
                numberDataCount++;
            }
        }
		CGFloat elipsisSize = 6.f;

		if (numberDataCount == 1) {
			for (NSUInteger valueIndex = 0; valueIndex < values.count; valueIndex++) {
				
				if ([@"NSCFNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex] class])] || [@"NSNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex] class])]) {
					if ([[values objectAtIndex:valueIndex] floatValue] == CGFLOAT_MIN)
						continue;
					NSUInteger x = valueIndex * stepX;
					CGFloat y = ([[values objectAtIndex:valueIndex] floatValue] - minY) * stepY;
					
					CGPoint startPoint = CGPointMake(x + offsetX, rect.size.height - y - offsetY);					
					CGRect elipsisRect = CGRectMake(startPoint.x-(elipsisSize/2), startPoint.y-(elipsisSize/2), elipsisSize, elipsisSize);
					
					CGContextAddEllipseInRect(c, elipsisRect);
					CGContextSetFillColorWithColor(c, plotColor);
					CGContextFillEllipseInRect(c, elipsisRect);
					
					CGContextClosePath(c);
				}
			}
		}
		
		if (numberDataCount >= 2) {
            for (NSUInteger valueIndex = 0; valueIndex < values.count - 1; valueIndex++) {
                if ([@"NSCFNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex] class])] || [@"NSNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex] class])]) {
					if ([[values objectAtIndex:valueIndex] floatValue] == CGFLOAT_MIN)
						continue;
					
					NSUInteger x = valueIndex * stepX;
                    CGFloat y = ([[values objectAtIndex:valueIndex] floatValue] - minY) * stepY;
                    
                    CGContextSetLineWidth(c, 2.f);
                    
                    CGPoint startPoint = CGPointMake(x + offsetX, rect.size.height - y - offsetY);
                    CGPoint endPoint;
					
					CGRect elipsisRect = CGRectMake(startPoint.x-(elipsisSize/2), startPoint.y-(elipsisSize/2), elipsisSize, elipsisSize);
					CGContextAddEllipseInRect(c, elipsisRect);
					CGContextSetFillColorWithColor(c, plotColor);
					CGContextFillEllipseInRect(c, elipsisRect);
					
                    if ([@"NSCFNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex + 1] class])] || [@"NSNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex + 1] class])]) {
                        x = (valueIndex + 1) * stepX;
                        y = ([[values objectAtIndex:valueIndex + 1] floatValue] - minY) * stepY;
                        endPoint = CGPointMake(x + offsetX, rect.size.height - y - offsetY);    						
                    } else {
                        for (NSUInteger idx = valueIndex+1; idx < values.count; idx++) {
                            if ([@"NSCFNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:idx] class])] || [@"NSNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:idx] class])]) {
                                x = idx * stepX;
                                y = ([[values objectAtIndex:idx] floatValue] - minY) * stepY;
                                endPoint = CGPointMake(x + offsetX, rect.size.height - y - offsetY);
                                break;
                            }
                        }
                    }
										
                    CGContextMoveToPoint(c, startPoint.x, startPoint.y);
                    
                    CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
					
                    CGContextClosePath(c);

                    CGContextSetStrokeColorWithColor(c, plotColor);
                    CGContextStrokePath(c);
                    
                    if (shouldFill) {
                        
                        CGContextMoveToPoint(c, startPoint.x, rect.size.height - offsetY);
                        CGContextAddLineToPoint(c, startPoint.x, startPoint.y);
                        CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
                        CGContextAddLineToPoint(c, endPoint.x, rect.size.height - offsetY);
                        CGContextClosePath(c);
                        
                        CGContextSetFillColorWithColor(c, plotColor);
                        CGContextFillPath(c);
                    }
					elipsisRect = CGRectMake(endPoint.x-(elipsisSize/2), endPoint.y-(elipsisSize/2), elipsisSize, elipsisSize);
					CGContextAddEllipseInRect(c, elipsisRect);
					CGContextSetFillColorWithColor(c, plotColor);
					CGContextFillEllipseInRect(c, elipsisRect);					
                }
            }
        }
	}
	
	if (_drawInfo) {
		
		font = [TexLegeTheme boldFourteen];
		[self.infoColor set];
		[_info drawInRect:CGRectMake(0.0f, 5.0f, rect.size.width, 20.0f) withFont:font
			lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	}
		
}

- (void)xAxisWasTapped:(UIButton *)sendor{
    NSArray *allOfSubviews = [self subviews];
    for (UIView *view in allOfSubviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.backgroundColor != _highlightColor) {
                CGContextRef context = UIGraphicsGetCurrentContext();
                [UIView beginAnimations:nil context:context];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDuration:0.3f];
                
                [view setBackgroundColor:[UIColor clearColor]];
                
                [UIView commitAnimations];
            }
        }
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = sendor.frame;
    [sendor setBounds:CGRectMake(rect.origin.x/2, rect.origin.y/2, 0, 0)];
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    
    [sendor setBackgroundColor:_highlightColor];
    [sendor setBounds:rect];
    [UIView commitAnimations];
    
    [self.delegate graphView:self indexOfTappedXaxis:sendor.tag];
}

- (void)reloadData {
	//remove buttons displayed.
    NSArray *allOfSubviews = [self subviews];
    for (UIView *view in allOfSubviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
	[self setNeedsDisplay];
}

#pragma mark PrivateMethods

- (void)initializeComponent {
	
	_drawAxisX = YES;
	_drawAxisY = YES;
	_drawGridX = YES;
	_drawGridY = YES;
	
	_xValuesColor = [[UIColor blackColor] retain];
	_yValuesColor = [[UIColor blackColor] retain];
	
	_gridXColor = [[UIColor blackColor] retain];
	_gridYColor = [[UIColor blackColor] retain];
	
	_drawInfo = NO;
	_infoColor = [[UIColor blackColor] retain];
	
	_highlightColor = [[UIColor colorWithWhite:0.9f alpha:0.2f] retain];
	
	/*
	 self.layer.shadowOffset = CGSizeMake(0, -1);
	self.layer.shadowColor = [[UIColor grayColor] CGColor];
	self.layer.shadowRadius = 5;
	self.layer.shadowOpacity = 1.f;//.25;
	
	CGRect shadowFrame = self.layer.bounds;
	CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
	self.layer.shadowPath = shadowPath;
	*/
	self.layer.cornerRadius = 10.f;
	self.layer.masksToBounds = YES;

}

@end
