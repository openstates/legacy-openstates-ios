//
//  GeneralTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"

#import "TableDataSourceProtocol.h"

@interface GeneralTableViewController : UITableViewController < UITableViewDelegate> {
}

@property (nonatomic,retain) NSIndexPath *selectIndexPathOnAppear;
@property (nonatomic,retain) id<TableDataSource> dataSource;
@property (nonatomic,retain) id detailViewController;

- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context;
@end
