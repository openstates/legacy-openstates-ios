//
//  MapImageView.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/18/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "MapImageView.h"
#import "DetailTableViewController.h"


@implementation MapImageView

@synthesize imageFile;
@synthesize viewController;


// initialize the view, calling super and setting the 
// properties to nil
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
        
		// Initialization code here.
		imageFile = nil;
		scrollView = nil;
		imageView = nil;
		viewController = nil;
		// set the background color of the view to clear
		self.backgroundColor=[UIColor clearColor];
		
		scrollView = [[UIScrollView alloc] initWithFrame:frame];
		scrollView.delegate = self;
		scrollView.bouncesZoom = YES;
		scrollView.backgroundColor = [UIColor blackColor];
		
		// Create a container view. We need to return this in -viewForZoomingInScrollView: below.
		imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[scrollView addSubview:imageView];
		[self addSubview:scrollView];

    }
    return self;
}

// yes this view can become first responder
- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)drawRect:(CGRect)rect {

	// Create an image view from our image file name
	if (imageFile != nil) {
/*
		CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("Map.Floors234.pdf"), NULL, NULL);
		pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		CFRelease(pdfURL);
*/
		UIImage *image = [UIImage imageNamed:imageFile];
		CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
		imageView.frame = frame;
		imageView.image = image;
        
		scrollView.contentSize = imageView.frame.size;
    
		// Minimum and maximum zoom scales
		scrollView.minimumZoomScale = scrollView.frame.size.width / image.size.width;
		scrollView.maximumZoomScale = 2.0;

	}	
	
	
}


// Implement the UIScrollView delegate method so that it knows which view to scale when zooming.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)dealloc {
	// the view controller is an assign, so just set it to nil
	viewController = nil;
	[imageFile release];
	[scrollView release];
	[super dealloc];
}


@end
