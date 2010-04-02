/*

File: TexLegeAppDelegate.m
Abstract: Application delegate that sets up the application.

Version: 1.7

*/

#import "TexLegeAppDelegate.h"
#import "PeriodicElements.h"
#import "AtomicElement.h"
#import "MainMenuDataSource.h"
#import "DirectoryDataSource.h"
#import "LegislationDataSource.h"
#import "CommitteesDataSource.h"
#import "MapImagesDataSource.h"
#import "GeneralTableViewController.h"



@implementation TexLegeAppDelegate

@synthesize tabBarController;
@synthesize portraitWindow;


- init {
	if (self = [super init]) {
		// initialize  to nil
		portraitWindow = nil;
		tabBarController = nil;
	}
	return self;
}

- (UINavigationController *)createNavigationControllerWrappingViewControllerForDataSourceOfClass:(Class)datasourceClass {
	// this is entirely a convenience method to reduce the repetition of the code
	// in the setupPortaitUserInterface
	// it returns a retained instance of the UINavigationController class. This is unusual, but 
	// it is necessary to limit the autorelease use as much as possible.
	
	// for each tableview 'screen' we need to create a datasource instance (the class that is passed in)
	// we then need to create an instance of GeneralTableViewController with that datasource instance
	// finally we need to return a UINaviationController for each screen, with the GeneralTableViewController
	// as the root view controller.
	
	// many of these require the temporary creation of objects that need to be released after they are configured
	// and factoring this out makes the setup code much easier to follow, but you can still see the actual
	// implementation here
	
	
	// the class type for the datasource is not crucial, but that it implements the 
	// TableDataSource protocol and the UITableViewDataSource Protocol is.
	id<TableDataSource,UITableViewDataSource> dataSource = [[datasourceClass alloc] init];
	
	// create the GeneralTableViewController and set the datasource
	GeneralTableViewController *theViewController;	
	theViewController = [[GeneralTableViewController alloc] initWithDataSource:dataSource];
	
	// create the navigation controller with the view controller
	UINavigationController *theNavigationController;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:theViewController];
	
	// before we return we can release the dataSource (it is now managed by the GeneralTableViewController instance
	[dataSource release];
	
	// and we can release the viewController because it is managed by the navigation controller
	[theViewController release];
	
	return theNavigationController;
}


- (void)setupPortraitUserInterface {
	// a local navigation variable
	// this is reused several times
	UINavigationController *localNavigationController;

    // Set up the portraitWindow and content view
	UIWindow *localPortraitWindow;
	localPortraitWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.portraitWindow = localPortraitWindow;
	// the localPortraitWindow data is now retained by the application delegate so we can release the local variable
	[localPortraitWindow release];

    [portraitWindow setBackgroundColor:[UIColor blackColor]];
    
	// Create a tabbar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:11];
	
	// ********** setup the various view controllers for the different data representations
	
	// create the view controller and datasource for the MainMenuDataSource
	// wrap it in a UINavigationController, and add that navigationController to the 
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[MainMenuDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	// the localNavigationController data is now retained by the application delegate so we can release the local variable
	[localNavigationController release];
	
	
	// repeat the process for the DirectoryDataSource
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[DirectoryDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	// repeat the process for the LegislationDataSource
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[LegislationDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	// repeat the process for the CommitteesDataSource
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[CommitteesDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	// repeat the process for the MapImagesDataSource
	localNavigationController = [self createNavigationControllerWrappingViewControllerForDataSourceOfClass:[MapImagesDataSource class]];
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = localViewControllersArray;
	[localViewControllersArray release];
	
	// set the window subview as the tab bar controller
	[portraitWindow addSubview:tabBarController.view];
	
	// make the window visible
	[portraitWindow makeKeyAndVisible];


}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// configure the portrait user interface
	[self setupPortraitUserInterface];
}


- (void)dealloc {
	[tabBarController release];
	[portraitWindow release];    
    [super dealloc];
}

@end

