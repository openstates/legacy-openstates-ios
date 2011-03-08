//
//  LinksMenuDataSource.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"

@interface LinksDataSource : NSObject <TableDataSource>  {
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
 