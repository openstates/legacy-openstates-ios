//
//  CommitteesDataSource.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"

@interface CommitteesDataSource : NSObject <TableDataSource> {
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSInteger filterChamber;		// 0 means don't filter
@property (nonatomic,retain) NSMutableString *filterString;	// @"" means don't filter
@property (nonatomic, readonly) BOOL hasFilter;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

- (void) setFilterByString:(NSString *)filter;
- (void) removeFilter;

#if NEEDS_TO_INITIALIZE_DATABASE == 1
- (void)initializeDatabase;	
#endif

@end
