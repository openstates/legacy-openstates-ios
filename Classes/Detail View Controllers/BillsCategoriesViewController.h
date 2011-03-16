//
//  BillsCategoriesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface BillsCategoriesViewController : UITableViewController <UITableViewDelegate> {
	NSMutableArray *_CategoriesList;
}
- (IBAction)refreshCategories:(NSNotificationCenter *)notification;

@end
