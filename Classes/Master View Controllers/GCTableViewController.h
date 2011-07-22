//
//  GCTableViewController.h
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-06-17.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import <UIKit/UIKit.h>

//Subclass of UIViewController that mimics the UITableViewController except that the tableView is a subview of self.view (as opposed to the view itself)
//Also allow changes in the frame of the tableView and other subviews to self.view

@interface GCTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) UITableView *tableView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (id) initWithStyle:(UITableViewStyle)style;

//Subclass if you want to change the type of tableView. The tableView will be automatically placed later
//(Usefull if you have a subclass of UITableView that you want to use)
- (UITableView*) tableViewWithStyle:(UITableViewStyle) style;

@end
