//
//  MapImagesDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "TableDataSourceProtocol.h"

@interface MapImagesDataSource : NSObject <UITableViewDataSource,TableDataSource, NSFetchedResultsControllerDelegate> {
	NSArray *InteriorMaps;
	NSArray *ExteriorMaps;
	NSArray *ChamberMaps;
	//NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;	
}
//@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (readonly,nonatomic,retain) NSArray *InteriorMaps;
@property (readonly,nonatomic,retain) NSArray *ExteriorMaps;
@property (readonly,nonatomic,retain) NSArray *ChamberMaps;

- (void) reload;

@end
