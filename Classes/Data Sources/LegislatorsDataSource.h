//
//  DirectoryDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//


#import "TableDataSourceProtocol.h"
#import "LegislatorObj.h"

@class LegislatorMasterTableViewCell;

@interface LegislatorsDataSource : NSObject <TableDataSource>  {
	BOOL hideTableIndex;
	NSInteger filterChamber;
	NSMutableString *filterString;
	
	IBOutlet LegislatorMasterTableViewCell *leg_cell;
	
	NSFetchedResultsController *fetchedResultsController;
	IBOutlet NSManagedObjectContext *managedObjectContext;	
	UISearchDisplayController *searchDisplayController;
#if NEEDS_TO_INITIALIZE_DATABASE
@private
	BOOL needsInitDB;
#endif
}
@property (nonatomic, retain) IBOutlet LegislatorMasterTableViewCell *leg_cell;

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
