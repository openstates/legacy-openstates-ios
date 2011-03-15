//
//  BillsListDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BillSearchDataSource;
@interface BillsListDetailViewController : UITableViewController <UITableViewDelegate> {
	IBOutlet BillSearchDataSource *dataSource;
	NSMutableDictionary *_requestDictionary;
	NSMutableDictionary *_requestSenders;
}
@property (nonatomic,retain) BillSearchDataSource *dataSource;

- (void)JSONRequestWithURLString:(NSString *)queryString sender:(id)sender;
- (IBAction)refreshBill:(NSDictionary *)watchedItem sender:(id)sender;

@end
