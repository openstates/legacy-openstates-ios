/*

File: AtomicElementTileView.m
Abstract: Draws the small tile view displayed in the tableview rows.

Version: 1.7

*/

#import "AtomicElementTileView.h"
#import "AtomicElement.h"


@implementation AtomicElementTileView
@synthesize element;

+ (CGSize)preferredViewSize {
	return CGSizeMake(37,37);
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		element = nil;
    }
    return self;
}
 
- (void)drawRect:(CGRect)rect {
	CGPoint point;
	// get the image that represents the element physical state and draw it
	UIImage *backgroundImage = element.stateImageForAtomicElementTileView;
	CGRect elementSymbolRectangle = CGRectMake(0,0, [backgroundImage size].width, [backgroundImage size].height);
	[backgroundImage drawInRect:elementSymbolRectangle];
	
	[[UIColor whiteColor] set];
	
	// draw the element number
	UIFont *font = [UIFont boldSystemFontOfSize:11];
	point = CGPointMake(3,2);
	[[element.atomicNumber stringValue] drawAtPoint:point withFont:font];
	
	// draw the element symbol
	font = [UIFont boldSystemFontOfSize:18];
	CGSize stringSize = [element.symbol sizeWithFont:font];
	point = CGPointMake((elementSymbolRectangle.size.width-stringSize.width)/2,14);
	
	[element.symbol drawAtPoint:point withFont:font];
}


- (void)dealloc {
	[element release];
	[super dealloc];
}


@end
