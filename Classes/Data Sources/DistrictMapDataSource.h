//
//  DistrictMapDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 8/23/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"

#if NEEDS_TO_PARSE_KMLMAPS == 1
@class DistrictMapImporter;
#endif

@interface DistrictMapDataSource : NSObject <TableDataSource> {
#if NEEDS_TO_PARSE_KMLMAPS == 1
	NSInteger mapCount;
#endif
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

#if NEEDS_TO_PARSE_KMLMAPS == 1
- (void)insertDistrictMaps:(NSArray *)districtMaps;
@property (nonatomic, retain) DistrictMapImporter *importer;
#endif

@end
