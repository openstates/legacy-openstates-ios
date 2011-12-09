//
//  SLFStackedViewController.m
//  Created by Greg Combs on 12/9/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFStackedViewController.h"

@interface SLFStackedViewController()
@property (nonatomic,retain) IBOutlet UINavigationBar *navigationBar;
@end

@implementation SLFStackedViewController
@synthesize navigationBar = navigationBar_;

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.topOffset = 54;
    }
    return self;
}

- (void)dealloc {
    self.navigationBar = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.navigationBar = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar = nil;
    navigationBar_ = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54)];
    [self.view addSubview:navigationBar_];
}
@end
