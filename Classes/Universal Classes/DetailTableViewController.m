/*

File: DetailTableViewController.m
Abstract: Controller that manages the full tile view of the atomic information,
creating the reflection, and the flipping of the tile.

*/

 
#import "DetailTableViewController.h"
#import "AtomicElementView.h"
#import "AtomicElementFlippedView.h"
#import "AtomicElement.h"

@implementation DetailTableViewController

@synthesize element;
@synthesize atomicElementFlippedView;
@synthesize atomicElementView;
@synthesize containerView;
@synthesize reflectionView;
@synthesize flipIndicatorButton;
@synthesize frontViewIsVisible;

//@synthesize mapImageView;
@synthesize mapFileName;
@synthesize webPDFView;


#define reflectionFraction 0.35
#define reflectionOpacity 0.5


- (id)init {
	if (self = [super init]) {
		element = nil;
		atomicElementView = nil;
		atomicElementFlippedView = nil;
		self.frontViewIsVisible=YES;
		self.hidesBottomBarWhenPushed = YES;

		mapFileName = nil;
//		mapImageView = nil;
		
		webPDFView = nil;
	}
	return self;
}


- (void)loadView {	
	// create and store a container view

	UIView *localContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.containerView = localContainerView;
	[localContainerView release];
	
	containerView.backgroundColor = [UIColor blackColor];
	
if (element != nil) {

	CGSize preferredAtomicElementViewSize = [AtomicElementView preferredViewSize];
	
	CGRect viewRect = CGRectMake((containerView.bounds.size.width-preferredAtomicElementViewSize.width)/2,
								 (containerView.bounds.size.height-preferredAtomicElementViewSize.height)/2-40,
								 preferredAtomicElementViewSize.width,preferredAtomicElementViewSize.height);
	
	// create the atomic element view
	AtomicElementView *localAtomicElementView = [[AtomicElementView alloc] initWithFrame:viewRect];
	self.atomicElementView = localAtomicElementView;
	[localAtomicElementView release];
	
	// add the atomic element view to the containerView
	atomicElementView.element = element;	
	[containerView addSubview:atomicElementView];
	atomicElementView.viewController = self;
	self.view = containerView;
	
	// create the atomic element flipped view
	AtomicElementFlippedView *localAtomicElementFlippedView = [[AtomicElementFlippedView alloc] initWithFrame:viewRect];
	self.atomicElementFlippedView = localAtomicElementFlippedView;
	[localAtomicElementFlippedView release];
	
	atomicElementFlippedView.element = element;	
	atomicElementFlippedView.viewController = self;

	// create the reflection view
	CGRect reflectionRect=viewRect;

	// the reflection is a fraction of the size of the view being reflected
	reflectionRect.size.height=reflectionRect.size.height*reflectionFraction;
	// and is offset to be at the bottom of the view being reflected
	reflectionRect=CGRectOffset(reflectionRect,0,viewRect.size.height);
	
	UIImageView *localReflectionImageView = [[UIImageView alloc] initWithFrame:reflectionRect];
	self.reflectionView = localReflectionImageView;
	[localReflectionImageView release];
	
	// determine the size of the reflection to create
	NSUInteger reflectionHeight=atomicElementView.bounds.size.height*reflectionFraction;
	
	// create the reflection image, assign it to the UIImageView and add the image view to the containerView
	reflectionView.image=[self.atomicElementView reflectedImageRepresentationWithHeight:reflectionHeight];
	reflectionView.alpha=reflectionOpacity;
	
	[containerView addSubview:reflectionView];
	
	
	UIButton *localFlipIndicator=[[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
	self.flipIndicatorButton=localFlipIndicator;
	[localFlipIndicator release];
	
	// front view is always visible at first
	[flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"flipper_list_blue.png"] forState:UIControlStateNormal];
	
	UIBarButtonItem *flipButtonBarItem;
	flipButtonBarItem=[[UIBarButtonItem alloc] initWithCustomView:flipIndicatorButton];
	
	[self.navigationItem setRightBarButtonItem:flipButtonBarItem animated:YES];
	[flipButtonBarItem release];
	
	[flipIndicatorButton addTarget:self action:@selector(flipCurrentView) forControlEvents:(UIControlEventTouchDown   )];
	 
	}
	else {
		UIWebView *localWebView = [[UIWebView alloc] initWithFrame:containerView.bounds];
		self.webPDFView = localWebView;
		self.webPDFView.backgroundColor=[UIColor blackColor];
		
		self.webPDFView.scalesPageToFit = YES;
		self.webPDFView.detectsPhoneNumbers = NO;
		self.webPDFView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		
		[localWebView release];
		/*
		 CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("Map.Floors234.pdf"), NULL, NULL);
		 pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		 CFRelease(pdfURL);
		 */
		NSString *appBundle = [NSString stringWithFormat:@"%@/TexLege.app/", NSHomeDirectory()];
		NSString *pdfPath = [ NSString stringWithFormat:@"%@%@",appBundle,mapFileName ];
		NSURL *url = [ NSURL fileURLWithPath:pdfPath ];
		
		NSURLRequest *request = [ NSURLRequest requestWithURL:url ];
		[ webPDFView loadRequest:request ];

		[containerView addSubview:webPDFView];
		self.view = containerView;
				
		/*		
		// create the map image view
		MapImageView *localMapImageView = [[MapImageView alloc] initWithFrame:containerView.bounds];
		self.mapImageView = localMapImageView;
		[localMapImageView release];
		
		mapImageView.imageFile = mapFileName;	
		[containerView addSubview:mapImageView];
		mapImageView.viewController = self;
		self.view = containerView;
		*/
	}
	
}

- (void)flipCurrentView {
	NSUInteger reflectionHeight;
	UIImage *reflectedImage;
	
	// disable user interaction during the flip
	containerView.userInteractionEnabled = NO;
	flipIndicatorButton.userInteractionEnabled = NO;
	
	// setup the animation group
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	
	// swap the views and transition
    if (frontViewIsVisible==YES) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:YES];
        [atomicElementView removeFromSuperview];
        [containerView addSubview:atomicElementFlippedView];
		
		
		// update the reflection image for the new view
		reflectionHeight=atomicElementFlippedView.bounds.size.height*reflectionFraction;
		reflectedImage = [atomicElementFlippedView reflectedImageRepresentationWithHeight:reflectionHeight];
		reflectionView.image=reflectedImage;
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:containerView cache:YES];
        [atomicElementFlippedView removeFromSuperview];
        [containerView addSubview:atomicElementView];
		// update the reflection image for the new view
		reflectionHeight=atomicElementView.bounds.size.height*reflectionFraction;
		reflectedImage = [atomicElementView reflectedImageRepresentationWithHeight:reflectionHeight];
		reflectionView.image=reflectedImage;
    }
	[UIView commitAnimations];
	
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];

	if (frontViewIsVisible==YES)
	{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:flipIndicatorButton cache:YES];
		[flipIndicatorButton setBackgroundImage:element.flipperImageForAtomicElementNavigationItem forState:UIControlStateNormal];
	}
	else
	{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:flipIndicatorButton cache:YES];
		[flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"flipper_list_blue.png"] forState:UIControlStateNormal];
		
	}
	[UIView commitAnimations];
	frontViewIsVisible=!frontViewIsVisible;
}


- (void)transitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// re-enable user interaction when the flip is completed.
	containerView.userInteractionEnabled = YES;
	flipIndicatorButton.userInteractionEnabled = YES;

}



- (void)dealloc {
	[webPDFView release];
	[mapFileName release];
//	[mapImageView release];

	[atomicElementView release];
	[reflectionView release];
	[atomicElementFlippedView release];
	[element release];
	[super dealloc];
}


@end
