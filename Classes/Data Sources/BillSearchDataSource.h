//
//  BillSearchViewController.h
//  Created by Gregory Combs on 2/20/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

#define USE_BILLTYPES_AS_SECTIONS 0

#define kBillSearchNotifyDataError	@"BILLSEARCH_DATA_ERROR"
#define kBillSearchNotifyDataLoaded	@"BILLSEARCH_DATA_LOADED"

@interface BillSearchDataSource : NSObject <UITableViewDataSource, RKRequestDelegate> {
	NSMutableDictionary* _sections;	
	NSMutableArray* _rows;
	NSInteger loadingStatus;

}
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UITableViewController *delegateTVC;

// This will tell the data source to produce a "loading" cell for the table whenever it's searching.
@property (nonatomic) BOOL useLoadingDataCell;

- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController;
- (id)initWithTableViewController:(UITableViewController *)newDelegate;

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
	
- (RKRequest*)startSearchWithQueryString:(NSString *)queryString params:(NSDictionary *)queryParams;


/////////// FULL-TEXT SEARCH

- (void)startSearchForText:(NSString *)searchString
					 state:(NSString *)inState 
				   session:(NSString *)inSession 
				   chamber:(NSInteger)inChamber;

- (void)startSearchForText:(NSString *)searchString 
				   chamber:(NSInteger)chamber;



/////////// SUBJECTS

- (void)startSearchForSubject:(NSString *)searchSubject 
						state:(NSString *)inState 
					  session:(NSString *)inSession 
					  chamber:(NSInteger)inChamber;

- (void)startSearchForSubject:(NSString *)searchSubject 
					  chamber:(NSInteger)chamber;


/////////// AUTHORS

- (void)startSearchForBillsAuthoredBy:(NSString *)searchSponsorID 
								state:(NSString *)inState 
							  session:(NSString *)inSession;

- (void)startSearchForBillsAuthoredBy:(NSString *)searchSponsorID;

@end

