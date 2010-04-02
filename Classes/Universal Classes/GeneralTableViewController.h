/*

File: GeneralTableViewController.h
Abstract: Coordinates the tableviews and element data sources. It also responds
 to changes of selection in the table view and provides the cells.

Version: 1.7

*/

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"

@class AtomicElement;

 
@interface GeneralTableViewController : UIViewController <UITableViewDelegate> {
	UITableView *theTableView;
	id<TableDataSource,UITableViewDataSource> dataSource;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) id<TableDataSource,UITableViewDataSource> dataSource;

- (id)initWithDataSource:(id<TableDataSource,UITableViewDataSource>)theDataSource;


@end
