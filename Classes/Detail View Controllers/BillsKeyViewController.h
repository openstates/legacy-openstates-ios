//
//  BillsKeyViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BillSearchDataSource;
@interface BillsKeyViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *keyBills_;
}
@property (nonatomic,retain) NSMutableArray *keyBills;

@end
