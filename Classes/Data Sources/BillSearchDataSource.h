//
//  BillSearchViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBillSearchNotifyDataError	@"BILLSEARCH_DATA_ERROR"
#define kBillSearchNotifyDataLoaded	@"BILLSEARCH_DATA_LOADED"

@interface BillSearchDataSource : NSObject <UITableViewDataSource> {
	NSMutableArray* _rows;
	NSMutableDictionary* _sections;
	IBOutlet UISearchDisplayController *searchDisplayController;
	IBOutlet UITableViewController *delegateTVC;
}
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UITableViewController *delegateTVC;

- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController;
- (id)initWithTableViewController:(UITableViewController *)newDelegate;

- (void)startSearchWithString:(NSString *)searchString chamber:(NSInteger)chamber;
- (void)startSearchForSubject:(NSString *)searchSubject chamber:(NSInteger)chamber;

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
	
@end

