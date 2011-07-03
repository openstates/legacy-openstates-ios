//
//  BillSearchViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

#define kBillSearchNotifyDataError	@"BILLSEARCH_DATA_ERROR"
#define kBillSearchNotifyDataLoaded	@"BILLSEARCH_DATA_LOADED"

@interface BillSearchDataSource : NSObject <UITableViewDataSource, RKRequestDelegate> {
	NSMutableArray* _rows;
	NSMutableDictionary* _sections;
	IBOutlet UISearchDisplayController *searchDisplayController;
	IBOutlet UITableViewController *delegateTVC;
	NSInteger loadingStatus;
}
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UITableViewController *delegateTVC;

// This will tell the data source to produce a "loading" cell for the table whenever it's searching.
@property (nonatomic) BOOL useLoadingDataCell;

- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController;
- (id)initWithTableViewController:(UITableViewController *)newDelegate;

- (RKRequest*)startSearchWithQueryString:(NSString *)queryString params:(NSDictionary *)queryParams;

// Convenience methods to fill out search parameters automatically
- (void)startSearchForText:(NSString *)searchString chamber:(NSInteger)chamber;
- (void)startSearchForSubject:(NSString *)searchSubject chamber:(NSInteger)chamber;
- (void)startSearchForBillsAuthoredBy:(NSString *)searchSponsorID;

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
	
@end

