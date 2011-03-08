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
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSInteger filterChamber;		// 0 means don't filter
@property (nonatomic,retain) NSMutableString *filterString;	// @"" means don't filter
@property (nonatomic, readonly) BOOL hasFilter;

- (void) setFilterByString:(NSString *)filter;
- (void) removeFilter;

@end
