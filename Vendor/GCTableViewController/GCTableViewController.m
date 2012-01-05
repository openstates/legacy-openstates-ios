//
//  GCTableViewController.m
//  GCLibrary
//  --- Heavily altered by Gregory S. Combs (https://github.com/grgcombs)
//
//  Created by Guillaume Campagna on 10-06-17.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import "GCTableViewController.h"

@implementation GCTableViewController
@synthesize tableView = _tableView;
@synthesize tableViewStyle = _tableViewStyle;
@synthesize onConfigureTableView = _onConfigureTableView;
@synthesize clearsSelectionOnViewWillAppear =  _clearsSelectionOnViewWillAppear;

- (id)init {
    self = [self initWithStyle:UITableViewStylePlain];
    return self;
}

- (id)initWithStyle:(UITableViewStyle) style {
    self = [self initWithStyle:style usingBlock:nil];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style usingBlock:(GCTableViewConfigurationBlock)block {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.tableViewStyle = style;
        self.clearsSelectionOnViewWillAppear = YES;
        self.onConfigureTableView = block;
    }
    return self;
}

- (void)dealloc {
    self.tableView = nil;
    Block_release(_onConfigureTableView);
    [super dealloc];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    if (self.onConfigureTableView)
        _onConfigureTableView(_tableView, self.tableViewStyle);
    _tableView.frame = self.view.bounds;
    [self.view addSubview:_tableView];
}

- (void)viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setOnConfigureTableView:(GCTableViewConfigurationBlock)onConfigureTableView {
    if (_onConfigureTableView) {
        Block_release(_onConfigureTableView);
        _onConfigureTableView = nil;
    }
    _onConfigureTableView = Block_copy(onConfigureTableView);
}


#pragma mark TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
