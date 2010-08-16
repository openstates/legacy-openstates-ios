//
//  LinksMenuDataSource.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "TableDataSourceProtocol.h"

@interface LinksDataSource : NSObject <TableDataSource>  {
		
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;

#if NEEDS_TO_INITIALIZE_DATABASE
@property (nonatomic,retain) NSArray * linksData;
- (void) setupDataArray;
- (void) initializeDatabase;
#endif

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

@end
 