//
//  BillsFavoritesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBillFavoritesStorageFile @"FavoriteBills.plist"

@interface BillsFavoritesViewController : UITableViewController <UITableViewDelegate> {
	NSMutableArray *_watchList;
	NSMutableDictionary *_requestDictionary;
	NSMutableDictionary *_requestSenders;
	NSMutableDictionary *_cachedBills;
}
- (void)JSONRequestWithURLString:(NSString *)queryString sender:(id)sender;
- (IBAction)refreshBill:(NSDictionary *)watchedItem sender:(id)sender;
- (IBAction)refreshAllBills:(id)sender;
	
@end
