//
//  GeneralTableViewController.m
//  Created by Gregory Combs on 7/10/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//


#import "GeneralTableViewController.h"

#import "TableDataSourceProtocol.h"
#import "BillsMenuDataSource.h"
#import "TexLegeTheme.h"
#import "TexLegeReachability.h"

#import "SLFPersistenceManager.h"
#import "StateMetaLoader.h"
#import "UtilityMethods.h"

@implementation GeneralTableViewController
@synthesize dataSource, detailViewController, controllerEnabled;
@synthesize selectObjectOnAppear;

#pragma mark -
#pragma mark Main Menu Info

+ (NSString *)name
{ return @""; }

- (NSString *)name 
{ return [[self class] name]; }

- (NSString *)navigationBarName 
{ return @""; }

+ (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"error"]; }


///////////////////////////////////////////////////////
- (void)configObserver {
    isFeatureEnabled = YES;
    isServerReachable = YES;
    controllerEnabled = YES;
    
    NSString *statusKey = [self reachabilityStatusKey];
    if (!IsEmpty(statusKey)) {
        [[TexLegeReachability sharedTexLegeReachability] addObserver:self 
                                                          forKeyPath:statusKey 
                                                             options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                                                             context:nil];			
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stateChanged:) 
                                                 name:kStateMetaNotifyStateLoaded // We've changed the current state, reconfigure
                                               object:nil];
        
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        [self configObserver];
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configObserver];
}

- (void)dealloc {
	[[TexLegeReachability sharedTexLegeReachability] removeObserver:self forKeyPath:[self reachabilityStatusKey]];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	//self.tableView = nil;
	self.dataSource = nil; 
	self.detailViewController = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}


///////////////////////////////////////////////////////

- (NSString *)reachabilityStatusKey {
	return nil;
}

- (NSString *)apiFeatureFlag {
    return nil;   // override this to test for availability of a feature for the active state in the open states api
}

- (void)stateChanged:(NSNotification *)notification {
    [self resetControllerEnabled:notification];
}

- (void)resetControllerEnabled:(NSNotification *)notification {
    
    if ([self apiFeatureFlag]) {
        isFeatureEnabled = [[StateMetaLoader sharedStateMeta] isFeatureEnabled:[self apiFeatureFlag]];
    }
    
    [self setControllerEnabled:(isFeatureEnabled == YES && isServerReachable == YES)];
    
}

- (void)setControllerEnabled:(BOOL)enabled {
    controllerEnabled = enabled;
    
    if (self.splitViewController)
        self.splitViewController.tabBarItem.enabled = controllerEnabled;
    
    if (self.navigationController)
        self.navigationController.tabBarItem.enabled = controllerEnabled;
    
    if (self.tabBarItem)
        self.tabBarItem.enabled = controllerEnabled;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (!IsEmpty(keyPath) && [self reachabilityStatusKey] && [keyPath isEqualToString:[self reachabilityStatusKey]]) {
		
		id newVal = [change valueForKey:NSKeyValueChangeNewKey];
		if (newVal && [newVal isKindOfClass:[NSNumber class]]) {
			isServerReachable = [newVal intValue] > NotReachable;
		}
                
        [self resetControllerEnabled:nil];        
	}
	/*if (!IsEmpty(keyPath) && [keyPath isEqualToString:@"frame"]) {
		NSLog(@"Class=%@ w=%f h=%f", NSStringFromClass([self class]), self.tableView.frame.size.width, self.tableView.frame.size.height);
	}*/	
}


///////////////////////////////////////////////////////


- (Class)dataSourceClass {
	return [NSObject class];
}

- (id<TableDataSource>)dataSource {
	if (!dataSource) {
		dataSource = [[[self dataSourceClass] alloc] init];
	}
	return dataSource;
}

- (void)configure {	
	
	SLFPersistenceManager *persistence = [SLFPersistenceManager sharedPersistence];
    
	[self dataSource];
	
    id object = [persistence tableSelectionForKey:NSStringFromClass([self class])];
    if (!object)
        return;
    
    if ([object isKindOfClass:[NSIndexPath class]] && NO == [self.dataSource isKindOfClass:[BillsMenuDataSource class]]) {
        self.selectObjectOnAppear = [self.dataSource dataObjectForIndexPath:object];
    }
	
	if (self.selectObjectOnAppear && self.detailViewController && [UtilityMethods isIPadDevice]) {
		NSLog(@"Presetting a detail view's dataObject in %@!", [self description]);
		if ([self.detailViewController respondsToSelector:@selector(setDataObject:)]) {
			@try {
				[self.detailViewController performSelector:@selector(setDataObject:) withObject:self.selectObjectOnAppear];
			}
			@catch (NSException * e) {
				self.selectObjectOnAppear = nil;
				//self.selectObjectOnAppear = [self.dataSource dataObjectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			}
		}
	}
	
}

- (void)runLoadView {	
	[super loadView];
    
    [self configObserver];
    
	/*
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	CGRect tempFrame = [[UIScreen mainScreen] applicationFrame];
	
	if (self.navigationController) {
		tempFrame = self.navigationController.view.bounds;
	}
	
	self.tableView = [[[UITableView alloc] initWithFrame:tempFrame style:[self.dataSource tableViewStyle]] autorelease];
	
	// set the cell separator to a single straight line.
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	//self.tableView.separatorColor = [UIColor lightGrayColor];
		
	self.tableView.sectionIndexMinimumDisplayRowCount=15;
	
	// set the tableview as the controller view
	//self.view = self.tableView;
	*/
}

-(void)viewDidLoad {
	[super viewDidLoad];
        
	//[self.navigationController.view addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
	    
	self.title = [self name];	
	// set the long name shown in the navigation bar
	//self.navigationItem.title=[dataSource navigationBarName];
	
	// FETCH CORE DATA
	if ([self.dataSource usesCoreData])
	{		
		NSError *error;
		// You've got to delete the cache, or disable caching before you modify the predicate...
		[NSFetchedResultsController deleteCacheWithName:[[dataSource fetchedResultsController] cacheName]];
		
		if (![[dataSource fetchedResultsController] performFetch:&error]) {
			// Handle the error...
		}					
	}

	self.tableView.dataSource = dataSource;
	if (self.searchDisplayController) {
		self.searchDisplayController.searchResultsDataSource = dataSource;
		if ([dataSource respondsToSelector:@selector(setSearchDisplayController:)])
			[dataSource performSelector:@selector(setSearchDisplayController:) withObject:self.searchDisplayController];
	}
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	self.tableView.delegate = self;
	
	self.clearsSelectionOnViewWillAppear = NO;
	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	//self.searchDisplayController.searchBar.tintColor = [TexLegeTheme accent];
	
	if ([UtilityMethods isIPadDevice]) {
		NSUInteger sectionCount = [self.tableView numberOfSections];
		CGFloat tableHeight = 0;
		NSInteger section = 0;
		for (section=0; section < sectionCount; section++) {
			tableHeight += [self.tableView rectForSection:section].size.height;
		}
		self.contentSizeForViewInPopover = CGSizeMake(320.0, tableHeight);
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDataChanged:) name:kNotifyTableDataUpdated object:self.dataSource];
}
	
- (void)viewDidUnload {
	//NSLog(@"--------------Unloading %@", NSStringFromClass([self class]));
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyTableDataUpdated object:self.dataSource];

	self.dataSource = nil;				//GREG

	self.detailViewController = nil;	// GREG
	[super viewDidUnload];
}

- (IBAction)selectDefaultObject:(id)sender {
	NSIndexPath *selectFirst = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView selectRowAtIndexPath:selectFirst animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self tableView:self.tableView didSelectRowAtIndexPath:selectFirst];
}

- (id)firstDataObject {
	NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	id detailObject = [self.dataSource dataObjectForIndexPath:currentIndexPath];			
	return detailObject;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// We're on an iphone, without a splitview or popovers, so if we get here, let's stop traversing our replay breadcrumbs
	if (![UtilityMethods isIPadDevice]) {
        
        [[SLFPersistenceManager sharedPersistence] setTableSelection:nil forKey:NSStringFromClass([self class])];
	}
}


#pragma -
#pragma UITableViewDelegate


- (void)tableDataChanged:(NSNotification *)aNotification {
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}


// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath withAnimation:(BOOL)animated {
	return ; // just a placeholder for children
}

// the *user* selected a row in the table, so turn on animations and save their selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	[self tableView:aTableView didSelectRowAtIndexPath:newIndexPath withAnimation:YES];
	
	// if we have a stack of view controllers and someone selected a new cell from our master list, 
	//	lets go all the way back to accomodate their selection.
	if ([UtilityMethods isIPadDevice]) {
		UINavigationController *detailNav = nil;
		if ([self.detailViewController respondsToSelector:@selector(navigationController)])
			detailNav = [self.detailViewController performSelector:@selector(navigationController)];
		
		if (!self.selectObjectOnAppear) {	// otherwise we pop whenever we're automatically selecting stuff ... right?
			if (detailNav && detailNav.viewControllers && [detailNav.viewControllers count] > 1) { 
				[detailNav popToRootViewControllerAnimated:YES];
				
				if ([self.detailViewController respondsToSelector:@selector(tableView)]) {
					UITableView *detailTable = [self.detailViewController performSelector:@selector(tableView)];
					if (detailTable) {
						CGRect guessTop = CGRectMake(0, 0, 10.0f, 10.0f);
						[detailTable scrollRectToVisible:guessTop animated:YES];
					}
				}
			}
		}
	}
}


#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 	
	return YES;
}


@end
