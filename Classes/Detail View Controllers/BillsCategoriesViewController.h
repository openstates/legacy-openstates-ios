//
//  BillsCategoriesViewController.h
//  Created by Gregory Combs on 2/25/11.
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
	NSInteger loadingStatus;
}
@property (nonatomic,retain) IBOutlet	UISegmentedControl *chamberControl;
@property (nonatomic,retain)	NSMutableDictionary *chamberCategories;
@property (nonatomic,readonly)	NSString *chamber; 

@end
