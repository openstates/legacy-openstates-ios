//
//  BillsMasterViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/6/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GeneralTableViewController.h"
@class BillSearchDataSource;

@interface BillsMasterViewController : GeneralTableViewController <UISearchDisplayDelegate> {
	IBOutlet BillSearchDataSource *billSearchDS;
	NSString *_searchString;
	NSMutableDictionary *_requestDictionary;
	NSMutableDictionary *_requestSenders;
}
@property (nonatomic,assign) IBOutlet BillSearchDataSource *billSearchDS;

- (void)JSONRequestWithURLString:(NSString *)queryString sender:(id)sender;

@end
