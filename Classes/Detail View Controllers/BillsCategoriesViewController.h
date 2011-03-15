//
//  BillsCategoriesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

#define kBillCategoriesFile @"BillMetadata.json"
#define kBillCategoriesPath @"BillMetadata"

@interface BillsCategoriesViewController : UITableViewController <UITableViewDelegate,RKRequestDelegate> {
	NSMutableArray *_CategoriesList;
}
- (IBAction)refreshCategories:(id)sender;

@end
