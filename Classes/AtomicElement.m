/*

File: AtomicElement.m
Abstract: Simple object that encapsulate the Atomic Element values and images
for the states.

Version: 1.7

*/

#import "AtomicElement.h"


@implementation AtomicElement

@synthesize atomicNumber;
@synthesize name;
@synthesize symbol;
@synthesize state;
@synthesize group;
@synthesize period;
@synthesize vertPos;
@synthesize horizPos;
@synthesize radioactive;
@synthesize atomicWeight;
@synthesize discoveryYear;

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	if ([self init]) {
		self.atomicNumber = [aDictionary valueForKey:@"atomicNumber"];
		self.atomicWeight = [aDictionary valueForKey:@"atomicWeight"];
		self.discoveryYear = [aDictionary valueForKey:@"discoveryYear"];
		self.radioactive = [[aDictionary valueForKey:@"radioactive"] boolValue];
		self.name = [aDictionary valueForKey:@"name"];
		self.symbol = [aDictionary valueForKey:@"symbol"];
		self.state = [aDictionary valueForKey:@"state"];
		self.group = [aDictionary valueForKey:@"group"];
		self.period = [aDictionary valueForKey:@"period"];
		self.vertPos = [aDictionary valueForKey:@"vertPos"];
		self.horizPos = [aDictionary valueForKey:@"horizPos"];

	}
	return self;
}

- (void)dealloc {
	[atomicNumber release];
	[atomicWeight release];
	[discoveryYear release];
	[name release];
	[symbol release];
	[state release];
	[group release];
	[period release];
	[vertPos release];
	[horizPos release];
	[super dealloc];
}
 
// this returns the position of the element in the classic periodic table locations
-(CGPoint)positionForElement {
	return CGPointMake([[self horizPos] intValue] * 26-8,[[self vertPos] intValue]*26+35);
	
}

- (UIImage *)stateImageForAtomicElementTileView {
	return [UIImage imageNamed:[NSString stringWithFormat:@"%@_37.png",state]];
}


- (UIImage *)stateImageForAtomicElementView {
	return [UIImage imageNamed:[NSString stringWithFormat:@"%@_256.png",state]];
}

- (UIImage *)stateImageForPeriodicTableView {
	return [UIImage imageNamed:[NSString stringWithFormat:@"%@_24.png",state]];
}


- (UIImage *)flipperImageForAtomicElementNavigationItem {
	
	// return a 30 x 30 image that is a reduced version
	// of the AtomicElementTileView content
	// this is used to display the flipper button in the navigation bar
	CGSize itemSize=CGSizeMake(30.0,30.0);
	UIGraphicsBeginImageContext(itemSize);
	
	UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_30.png",state]];
	CGRect elementSymbolRectangle = CGRectMake(0,0, itemSize.width, itemSize.height);
	[backgroundImage drawInRect:elementSymbolRectangle];

	// draw the element name
	[[UIColor whiteColor] set];
	
	// draw the element number
	UIFont *font = [UIFont boldSystemFontOfSize:8];
	CGPoint point = CGPointMake(2,1);
	[[self.atomicNumber stringValue] drawAtPoint:point withFont:font];
	
	// draw the element symbol
	font = [UIFont boldSystemFontOfSize:13];
	CGSize stringSize = [self.symbol sizeWithFont:font];
	point = CGPointMake((elementSymbolRectangle.size.width-stringSize.width)/2,10);
	
	[self.symbol drawAtPoint:point withFont:font];
	
	UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}



@end
