//
//  GCTableViewController.m
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-06-17.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import "GCTableViewController.h"

@implementation GCTableViewController
@synthesize tableView;
@synthesize clearsSelectionOnViewWillAppear;

- (id) init {
    self = [self initWithStyle:UITableViewStylePlain];
    return self;
}

- (id) initWithStyle:(UITableViewStyle) style {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        tableView = [[self tableViewWithStyle:style] retain];
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    [super dealloc];
}

- (void) loadView {
    [super loadView];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
}

- (void) viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark TableView methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark Getter

- (UITableView *) tableViewWithStyle:(UITableViewStyle)style {
    UITableView *aTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:style] autorelease];
    aTableView.delegate = self;
    aTableView.dataSource = self;
    return aTableView;
}

@end
