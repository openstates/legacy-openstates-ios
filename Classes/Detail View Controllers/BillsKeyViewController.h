//
//  BillsKeyViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/14/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@class BillSearchDataSource;
@interface BillsKeyViewController : UITableViewController <RKRequestDelegate, UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *keyBills_;
	NSInteger loadingStatus;
}
@property (nonatomic,retain) NSMutableArray *keyBills;

@end
