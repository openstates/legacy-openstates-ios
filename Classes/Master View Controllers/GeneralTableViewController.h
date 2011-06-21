//
//  GeneralTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//


#import "TableDataSourceProtocol.h"

@interface GeneralTableViewController : UITableViewController <UITableViewDelegate> {
	IBOutlet id detailViewController;
	IBOutlet id<TableDataSource> dataSource;
			 id	selectObjectOnAppear;
	NSNumber *controllerEnabled;
}

@property (nonatomic,retain) IBOutlet id<TableDataSource> dataSource;
@property (nonatomic,retain) IBOutlet id detailViewController;
@property (nonatomic,retain)		  id selectObjectOnAppear;
@property (nonatomic,retain) NSNumber *controllerEnabled;

- (NSString *)reachabilityStatusKey;

- (void)configure;
- (void)runLoadView;
- (Class)dataSourceClass;
- (IBAction)selectDefaultObject:(id)sender;
- (id)firstDataObject;

- (void)beginUpdates:(NSNotification *)aNotification;
- (void)endUpdates:(NSNotification *)aNotification;

@end
