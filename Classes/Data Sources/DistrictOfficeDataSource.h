//
//  DistrictOfficeDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 8/23/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"


@interface DistrictOfficeDataSource : NSObject <TableDataSource> {

}

@property (nonatomic, retain)			NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet	NSManagedObjectContext *managedObjectContext;

@property (nonatomic)			NSInteger filterChamber;		// 0 means don't filter
@property (nonatomic,retain)	NSMutableString *filterString;	// @"" means don't filter
@property (nonatomic, readonly) BOOL hasFilter;
@property (nonatomic)			BOOL byDistrict;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;
- (void) setFilterByString:(NSString *)filter;
- (void) removeFilter;
- (IBAction) sortByType:(id)sender;


@end
