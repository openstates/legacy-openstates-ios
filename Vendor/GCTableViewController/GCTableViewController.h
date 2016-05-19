//
//  GCTableViewController.h
//  GCLibrary
//  --- Heavily altered by Gregory S. Combs (https://github.com/grgcombs)
//
//  Created by Guillaume Campagna on 10-06-17.
//  Copyright 2010 LittleKiwi. All rights reserved.

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

/*** Subclass of UIViewController that mimics the UITableViewController except that the tableView is a subview 
   of self.view (as opposed to the view itself). Also allow changes in the frame of the tableView 
   and other subviews to self.view
 ***/

typedef void (^GCTableViewConfigurationBlock)(UITableView* tableView, UITableViewStyle style);

@interface GCTableViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,assign) BOOL clearsSelectionOnViewWillAppear;
@property (nonatomic,assign) UITableViewStyle tableViewStyle;
@property (nonatomic,copy) GCTableViewConfigurationBlock onConfigureTableView;

- (id)initWithStyle:(UITableViewStyle)style usingBlock:(GCTableViewConfigurationBlock)block;
- (id)initWithStyle:(UITableViewStyle)style;

@end
