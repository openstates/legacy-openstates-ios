//
//  BillsListViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BillSearchDataSource;
@interface BillsListViewController : UITableViewController <UITableViewDelegate> {
	IBOutlet BillSearchDataSource *dataSource;
}
@property (nonatomic,retain) BillSearchDataSource *dataSource;

@end
