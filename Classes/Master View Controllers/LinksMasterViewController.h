//
//  LinksMasterViewController.h
//  TexLege
//
//  Created by Gregory Combs on 8/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#import "TableDataSourceProtocol.h"
#import "AboutViewController.h"

@class MiniBrowserController;
@interface LinksMasterViewController : UITableViewController <UITableViewDelegate> {
}

@property (nonatomic,retain) id<TableDataSource> dataSource;
@property (nonatomic,retain) id detailViewController;
@property (nonatomic,readonly) NSString			*viewControllerKey;
@property (nonatomic,retain) id					selectObjectOnAppear;
@property (nonatomic,retain) AboutViewController *aboutControl;
@property (nonatomic,retain) MiniBrowserController *miniBrowser;

- (void)configureWithDataSourceClass:(Class)sourceClass andManagedObjectContext:(NSManagedObjectContext *)context;
@end
