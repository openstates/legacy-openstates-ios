//
//  BillsCategoriesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBillCategoriesFile @"BillMetadata.json"
#define kBillCategoriesPath @"BillMetadata"

@interface BillsCategoriesViewController : UITableViewController <UITableViewDelegate> {
	NSMutableArray *_CategoriesList;
//	NSMutableDictionary *_requestDictionary;
//	NSMutableDictionary *_requestSenders;
//	NSMutableDictionary *_cachedBills;
}
//- (void)JSONRequestWithURLString:(NSString *)queryString sender:(id)sender;
//- (IBAction)refreshBill:(NSDictionary *)watchedItem sender:(id)sender;
//- (IBAction)refreshAllBills:(id)sender;

- (IBAction)refreshCategories:(id)sender;

@end
