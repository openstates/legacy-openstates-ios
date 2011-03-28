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

#define ChartLabelID 62552

@interface LabelThingy : UIView {
	
}
@property (nonatomic,retain) NSString *labelText;
@property (nonatomic,retain) UIColor *labelColor;

@end

@implementation LabelThingy
@synthesize labelText, labelColor;
- (id)initWithFrame:(CGRect)frame {
	if (self=[super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.tag = ChartLabelID;
	}
	return self;
}

- (void)dealloc {
	self.labelText = nil;
	[super dealloc];
}

- (void) displayBarBox: (CGSize) stringSize offsetY: (CGFloat) offsetY displayX: (CGFloat) displayX c: (CGContextRef) c valueString: (NSString *) valueString color:(UIColor *)currentColor {
	// Build the rounded rectangle box for the display
	
	CGRect displayBar;
	CGPoint topLeftCorner = CGPointMake(displayX, offsetY-stringSize.height);
	CGPoint bottomLeftCorner = CGPointMake(topLeftCorner.x, topLeftCorner.y+([TexLegeTheme boldTen].pointSize+5.0));
	CGPoint topRightCorner = CGPointMake(topLeftCorner.x+stringSize.width+5.0, topLeftCorner.y);
	CGPoint bottomRightCorner = CGPointMake(topRightCorner.x, bottomLeftCorner.y);
	
	CGFloat radius = (bottomRightCorner.y - topRightCorner.y)/2;
	
	// Draw the arcs for the rounded box
	CGContextAddArc(c, topRightCorner.x, topRightCorner.y+radius, radius, 3.14/2, (3/2)*(3.14), 1);
	CGContextSetFillColorWithColor(c, currentColor.CGColor);
	CGContextFillPath(c);
	CGContextAddArc(c, topLeftCorner.x, topLeftCorner.y+radius, radius,  0, (2)*(3.14), 0);
	CGContextSetFillColorWithColor(c, currentColor.CGColor);
	CGContextFillPath(c);
	CGFloat displayY = (offsetY-stringSize.height);
	displayBar = CGRectMake(displayX, displayY, stringSize.width+5.0, [TexLegeTheme boldTen].pointSize+5.0);

	CGContextAddRect(c ,displayBar);
	CGContextFillRect(c, displayBar);
	
	CGContextSetFillColorWithColor(c, currentColor.CGColor);
	
	CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);
	CGSize offset = CGSizeMake(-1.5, -1.5 );
	UIColor * shadow = RGB( 50, 50, 50);
	CGContextSetShadowWithColor(c, offset, 2, shadow.CGColor);
	[valueString drawInRect:displayBar withFont:[TexLegeTheme boldTen]
			  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	CGContextSetShadowWithColor(c, offset, 0, NULL);
	//NSLog(@"%@ - %f", valueString,[valueString sizeWithFont:_detailFont].width);
	CGContextSetFillColorWithColor(c, [TexLegeTheme textLight].CGColor);
	
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize stringSize = [self.labelText sizeWithFont:[TexLegeTheme boldTen]];
	CGFloat displayX = ((rect.size.width/2)-stringSize.width/2);	
	[self displayBarBox:stringSize offsetY:(rect.size.height/2) displayX:displayX c:context valueString:self.labelText color:self.labelColor];	
}

@end


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
	
	NSDictionary *minmax = [self.dataSource graphViewMinAndMaxY:self];
	if (minmax) {
		minY = [[minmax objectForKey:@"minY"] floatValue];
		maxY = [[minmax objectForKey:@"maxY"] floatValue];
	}

	CGFloat offsetX = _drawAxisY ? 60.0f : 10.0f;
	CGFloat offsetY = (_drawAxisX || _drawInfo) ? 30.0f : 10.0f;
		
	UIFont *font = [TexLegeTheme boldTen];
	
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
                    CGPoint endPoint = {CGFLOAT_MIN,CGFLOAT_MIN};
					
					CGRect elipsisRect = CGRectMake(startPoint.x-(elipsisSize/2), startPoint.y-(elipsisSize/2), elipsisSize, elipsisSize);
					CGContextAddEllipseInRect(c, elipsisRect);
					CGContextSetFillColorWithColor(c, plotColor);
					CGContextFillEllipseInRect(c, elipsisRect);
					
					BOOL skipNext = NO;
                    if ([@"NSCFNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex + 1] class])] || [@"NSNumber" isEqualToString:NSStringFromClass([[values objectAtIndex:valueIndex + 1] class])]) {
						CGFloat nextVal = [[values objectAtIndex:valueIndex+1] floatValue];
						x = (valueIndex + 1) * stepX;
						y = (nextVal - minY) * stepY;
						endPoint = CGPointMake(x + offsetX, rect.size.height - y - offsetY); 
						skipNext = (nextVal == CGFLOAT_MIN || nextVal == 0.0f);
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

					// don't put a line on a missing value
					if (!skipNext)
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
					// don't put a dot on a missing value
					if (!skipNext) {
						elipsisRect = CGRectMake(endPoint.x-(elipsisSize/2), endPoint.y-(elipsisSize/2), elipsisSize, elipsisSize);
						CGContextAddEllipseInRect(c, elipsisRect);
						CGContextSetFillColorWithColor(c, plotColor);
						CGContextFillEllipseInRect(c, elipsisRect);	
					}
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
		else if (view.tag == ChartLabelID)
			[view removeFromSuperview];
    }
		
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = sendor.frame;
	
    [sendor setBounds:CGRectMake(rect.origin.x/2, rect.origin.y/2, 0, 0)];
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    
    [sendor setBackgroundColor:_highlightColor];
    [sendor setBounds:rect];
	
	NSNumber *repV = [[self.dataSource graphView:self yValuesForPlot:0] objectAtIndex:sendor.tag];
	NSNumber *memV = [[self.dataSource graphView:self yValuesForPlot:1] objectAtIndex:sendor.tag];
	NSNumber *demV = [[self.dataSource graphView:self yValuesForPlot:2] objectAtIndex:sendor.tag];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:1];
    [numberFormatter setMaximumFractionDigits:1];
	
	
	NSDictionary *repub = [[NSDictionary alloc] initWithObjectsAndKeys:
						   [NSNumber numberWithInteger:0], @"plotIndex",
						   [TexLegeTheme texasRed], @"color",
						   [numberFormatter stringFromNumber:repV], @"valueString",
						   nil];
	
	NSDictionary *member = [[NSDictionary alloc] initWithObjectsAndKeys:
							[NSNumber numberWithInteger:1], @"plotIndex",
							[TexLegeTheme accent], @"color",
							[numberFormatter stringFromNumber:memV], @"valueString",
							nil];
	
	NSDictionary *dem = [[NSDictionary alloc] initWithObjectsAndKeys:
							[NSNumber numberWithInteger:2], @"plotIndex",
							[TexLegeTheme texasBlue], @"color",
							[numberFormatter stringFromNumber:demV], @"valueString",
							nil];

	NSArray *order = nil;
	// set the visual order of the labels
	if ([memV floatValue] > [repV floatValue])
		order = [[NSArray alloc] initWithObjects:member, repub, dem, nil];
	else if ([memV floatValue] < [demV floatValue])
		order = [[NSArray alloc] initWithObjects:repub, dem, member, nil];
	else
		order = [[NSArray alloc] initWithObjects:repub, member, dem, nil];
		
	
	// this sets up the vertical spacing of the labels, evenly across the chart
	CGFloat height = self.frame.size.height - 30.f;
	CGFloat step = (height / 3)-15.f;
	
	// this shifts the labels to the left or right side, in we're touching too close to the edge of the chart
	CGFloat xShift = sendor.frame.origin.x+10.f;
	NSInteger lastIndex = [self.dataSource graphViewMaximumNumberOfXaxisValues:self] - 1;
	if (sendor.tag > 0 && sendor.tag >= lastIndex)
		xShift = xShift-90.f;
	
		
	NSInteger index = 1;
	for (NSDictionary *dict in order) {
		NSInteger plotIndex = [[dict objectForKey:@"plotIndex"] integerValue];
		NSString *labelString = [NSString stringWithFormat:@"%@: %@",
								 [self.dataSource graphView:self nameForPlot:plotIndex], 
								 [dict objectForKey:@"valueString"]];
		CGSize stringSize = [labelString sizeWithFont:[TexLegeTheme boldTen]];

		CGRect labelRect = CGRectMake(xShift, step*index,stringSize.width+30.f,stringSize.height+15.f); 
		LabelThingy *newLabel = [[LabelThingy alloc] initWithFrame:labelRect];
		newLabel.labelText = labelString;
		newLabel.labelColor = [dict objectForKey:@"color"];
		[self addSubview:newLabel];
		[newLabel release];
		index++;
		
	}
	[numberFormatter release];
	[member release];
	[repub release];
	[dem release];
	[order release];
		
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
		else if (view.tag == ChartLabelID)
			[view removeFromSuperview];
    }
    
	[self setNeedsDisplay];
}

#pragma mark PrivateMethods

- (void)initializeComponent {
	
	minY = CGFLOAT_MIN;
	maxY = CGFLOAT_MAX;
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
