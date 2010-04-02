//
//  LinksMenuDataSource.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "TableDataSourceProtocol.h"

@interface LinksMenuDataSource : NSObject <UITableViewDataSource,TableDataSource, NSFetchedResultsControllerDelegate>  {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
#if NEEDS_TO_INITIALIZE_DATABASE
	NSArray *linksData;
#endif
	
	UITableView *theTableView;
	BOOL	moving;
}
@property (nonatomic) BOOL moving;

@property (nonatomic, retain) UITableView *theTableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

#if NEEDS_TO_INITIALIZE_DATABASE
@property (nonatomic,retain) NSArray * linksData;
- (void) setupDataArray;
- (void) initializeDatabase;
#endif

- (NSArray *) getActionForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL) isAddLinkPlaceholderAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;


@end
 