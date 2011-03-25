//
//  BillsCategoriesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

#define kBillCategoriesNotifyError	@"BILL_CATEGORIES_ERROR"
#define kBillCategoriesNotifyLoaded	@"BILL_CATEGORIES_LOADED"
#define kBillCategoriesCacheFile	@"BillCategoriesCache.plist"

// "categories" returns an array of categories and counts, keyed by chamber type (NSNumber)
#define kBillCategoriesTitleKey		@"title"
#define kBillCategoriesCountKey		@"total"

@interface BillsCategoriesViewController : UITableViewController <RKRequestDelegate, UITableViewDelegate> {
	NSMutableDictionary *categories_;
	IBOutlet UISegmentedControl *chamberControl;
	BOOL isFresh;
	NSDate *updated;
}
@property (nonatomic,retain) IBOutlet	UISegmentedControl *chamberControl;
@property (nonatomic,retain)	NSMutableDictionary *chamberCategories;
@property (nonatomic,readonly)	NSNumber *chamber; 

@end
