//
//  BillsDataSource.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "TableDataSourceProtocol.h"

@interface BillsDataSource : NSObject <TableDataSource>  {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;	
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;



@end
