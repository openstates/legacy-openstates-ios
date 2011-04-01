//
//  BillsRecentViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@class BillSearchDataSource;
@interface BillsRecentViewController : UITableViewController <RKRequestDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *recentBills_;
}
@property (nonatomic,retain) NSMutableArray *recentBills;

@end
