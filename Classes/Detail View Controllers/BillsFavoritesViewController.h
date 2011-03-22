//
//  BillsFavoritesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

#define kBillFavoritesStorageFile @"FavoriteBills.plist"

@interface BillsFavoritesViewController : UITableViewController <RKRequestDelegate, UITableViewDelegate> {
	NSMutableArray *_watchList;
	NSMutableDictionary *_cachedBills;
}
- (IBAction)loadBills:(id)sender;
	
@end
