//
//  LinksDetailViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Constants.h"

@class LinkObj, EditingTableViewCell, LinksMenuDataSource;

@interface LinksDetailViewController : UITableViewController {
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) LinksMenuDataSource *mainDataSource;
@property (nonatomic, retain) LinkObj *link;
@property (nonatomic, assign) IBOutlet EditingTableViewCell *editingTableViewCell;

- (id)initWithStyle:(UITableViewStyle)style context:(NSManagedObjectContext *)context dataSource:(LinksMenuDataSource *)dataSource;

@end
