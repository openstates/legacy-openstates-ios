//
//  GeneralTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"

#import "TableDataSourceProtocol.h"

#define _searchcontroller_ 0

@interface GeneralTableViewController : UIViewController < UITableViewDelegate, UISearchBarDelegate 
#if _searchcontroller_
			,UISearchDisplayDelegate
#endif
> {

	UITableView *theTableView;
	id<TableDataSource> dataSource;
	id detailViewController;
	
	UISearchBar		*searchBar;
    NSString	*savedSearchTerm;
    BOOL		searchWasActive;
	
	IBOutlet UIBarButtonItem *menuButton;
	IBOutlet UIBarButtonItem *aboutButton;
	
#if _searchcontroller_
	UISearchDisplayController *searchController;
    NSInteger	savedScopeButtonIndex;
#endif	
}

//@property (nonatomic, retain) NSMutableArray savedLocation;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *aboutButton;


@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) id<TableDataSource> dataSource;
@property (nonatomic,retain) id detailViewController;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

#if _searchcontroller_
@property (nonatomic, retain) UISearchDisplayController *searchController; 
@property (nonatomic) NSInteger savedScopeButtonIndex;
#endif

- (void)toolbarAction:(id)sender;
- (void)toolBarSetup;

//- (id)initWithDataSource:(id<TableDataSource>)theDataSource;
- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope;

@property (nonatomic,readonly) NSString *functionalViewControllerName;
@property (nonatomic,readonly) NSString *detailViewControllerName;
@end
