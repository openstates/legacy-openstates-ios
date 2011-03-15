//
//  BillSearchViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillSearchDataSource : NSObject <UITableViewDataSource> {
	NSMutableArray* _rows;
	NSMutableData * _data;
	NSURLConnection *_activeConnection;
	IBOutlet UISearchDisplayController *searchDisplayController;
	IBOutlet UITableViewController *delegateTVC;
}
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) IBOutlet UITableViewController *delegateTVC;
@property (nonatomic, readonly) NSArray *billResults;

- (void)startSearchWithString:(NSString *)searchString chamber:(NSInteger)chamber;
- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController;

- (id)initWithTableViewController:(UITableViewController *)newDelegate;
- (void)startSearchForSubject:(NSString *)searchSubject chamber:(NSInteger)chamber;

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
	
@end

