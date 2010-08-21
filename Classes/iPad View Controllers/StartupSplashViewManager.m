    //
//  StartupSplashViewManager.m
//  TexLege
//
//  Created by Gregory Combs on 8/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "StartupSplashViewManager.h"


@implementation StartupSplashViewManager
@synthesize splashView, masterVC;

SYNTHESIZE_SINGLETON_FOR_CLASS(StartupSplashViewManager)
- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (UIView *)splashView {
	if (!splashView) {
		NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StartupSplashView-Portrait" owner:self options:NULL];
		splashView = [[objects objectAtIndex:0] retain];	
	}
	return splashView;
}

/*
- (void)
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
*/

/*
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.view = nil;
	self.masterVC = nil;
}
*/

- (void)dealloc {
    [super dealloc];
	self.splashView = nil;
	self.masterVC = nil;
}


@end
