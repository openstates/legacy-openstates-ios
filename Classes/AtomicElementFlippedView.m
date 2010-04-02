/*

File: AtomicElementFlippedView.m
Abstract: Displays the Atomic Element information with a link to Wikipedia.

Version: 1.7

*/

#import "AtomicElementView.h"
#import "AtomicElement.h"
#import "PeriodicElements.h"
#import "AtomicElementFlippedView.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation AtomicElementFlippedView

@synthesize wikipediaButton;

 
-(void)setupUserInterface {
	CGRect buttonFrame = CGRectMake(10.0, 209.0, 234.0, 37.0);
	// create the button
	self.wikipediaButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	self.wikipediaButton.frame=buttonFrame;
	
	[self.wikipediaButton setTitle:@"View at Wikipedia" forState:UIControlStateNormal];	
	self.wikipediaButton.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
	//self.wikipediaButton.tintColor=[UIColor lightGrayColor];
	
	// Center the text on the button, considering the button's shadow
	self.wikipediaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	self.wikipediaButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	[self.wikipediaButton addTarget:self action:@selector(jumpToWikipedia:) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:self.wikipediaButton];
	return;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) 
	{
		[self setAutoresizesSubviews:YES];
		[self setupUserInterface];
		
		// set the background color of the view to clearn
		self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (void)jumpToWikipedia:(id)sender {
	// create the string that points to the correct Wikipedia page for the element name
	NSString *wikiPageString = [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@",element.name];
	if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:wikiPageString]])
	{
		// there was an error trying to open the URL. for the moment we'll simply ignore it.
	}
}


- (void)drawRect:(CGRect)rect {
	
	// get the background image for the state of the element
	// position it appropriately and draw the image
	UIImage *backgroundImage = [element stateImageForAtomicElementView];
	CGRect elementSymbolRectangle = CGRectMake(0,0, [backgroundImage size].width, [backgroundImage size].height);
	[backgroundImage drawInRect:elementSymbolRectangle];
	
	// all the text is drawn in white
	[[UIColor whiteColor] set];
	
	
	// draw the element number
	UIFont *font = [UIFont boldSystemFontOfSize:32];
	CGPoint point = CGPointMake(10,5);
	[[NSString stringWithFormat:@"%@",element.atomicNumber] drawAtPoint:point withFont:font];
	
	// draw the element symbol
	CGSize stringSize = [element.symbol sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width-10),5);
	[element.symbol drawAtPoint:point withFont:font];
	
	// draw the element name
	font = [UIFont boldSystemFontOfSize:36];
	stringSize = [element.name sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width)/2,50);
	[element.name drawAtPoint:point withFont:font];
	
	
	float verticalStartingPoint=95;
	
	// draw the element weight
	font = [UIFont boldSystemFontOfSize:14];
	NSString *atomicWeightString=[NSString stringWithFormat:@"Atomic Weight: %@",element.atomicWeight];
	stringSize = [atomicWeightString sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width)/2,verticalStartingPoint);
	[atomicWeightString drawAtPoint:point withFont:font];
	
	// draw the element state
	font = [UIFont boldSystemFontOfSize:14];
	NSString *stateString=[NSString stringWithFormat:@"State: %@",element.state];
	stringSize = [stateString sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width)/2,verticalStartingPoint+20);
	[stateString drawAtPoint:point withFont:font];
	
	// draw the element period
	font = [UIFont boldSystemFontOfSize:14];
	NSString *periodString=[NSString stringWithFormat:@"Period: %@",element.period];
	stringSize = [periodString sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width)/2,verticalStartingPoint+40);
	[periodString drawAtPoint:point withFont:font];

	// draw the element group
	font = [UIFont boldSystemFontOfSize:14];
	NSString *groupString=[NSString stringWithFormat:@"Group: %@",element.group];
	stringSize = [groupString sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width)/2,verticalStartingPoint+60);
	[groupString drawAtPoint:point withFont:font];
	
	// draw the discovery year
	NSString *discoveryYearString = [NSString stringWithFormat:@"Discovered: %@",element.discoveryYear];
	stringSize = [discoveryYearString sizeWithFont:font];
	point = CGPointMake((self.bounds.size.width-stringSize.width)/2,verticalStartingPoint+80);
	[discoveryYearString drawAtPoint:point withFont:font];
	
	
	
}

- (void)dealloc {
	[wikipediaButton release];
	[super dealloc];
}

@end
