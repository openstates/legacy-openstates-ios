//
//  CommitteesDataSource.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "TableDataSourceProtocol.h"

@interface CommitteesDataSource : NSObject <TableDataSource> {
	BOOL hideTableIndex;
	NSInteger filterChamber;
	NSMutableString *filterString;

	NSFetchedResultsController *fetchedResultsController;
	IBOutlet NSManagedObjectContext *managedObjectContext;	
	UISearchDisplayController *searchDisplayController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSInteger filterChamber;		// 0 means don't filter
@property (nonatomic,retain) NSMutableString *filterString;	// @"" means don't filter
@property (nonatomic, readonly) BOOL hasFilter;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

- (void) setFilterByString:(NSString *)filter;
- (void) removeFilter;

#if NEEDS_TO_INITIALIZE_DATABASE
- (void)initializeDatabase;	
#endif

@end
