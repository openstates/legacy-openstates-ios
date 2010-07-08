//
//  LinksDetailViewController.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Constants.h"

@class LinkObj, EditingTableViewCell;

@interface LinksDetailViewController : UITableViewController {
	IBOutlet UISegmentedControl *commonMenuControl;
    @private
	LinkObj *link;
	NSFetchedResultsController * fetchedResultsController;
	
	EditingTableViewCell *editingTableViewCell;
}

@property (nonatomic, retain) LinkObj *link;
@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, assign) IBOutlet EditingTableViewCell *editingTableViewCell;
@property (nonatomic, retain) IBOutlet UISegmentedControl *commonMenuControl;

- (id)initWithStyle:(UITableViewStyle)style resultsController:(NSFetchedResultsController *)controller;

@end
