//
//  BillSearchViewController.h
//  TexLege
//
//  Created by Gregory Combs on 2/20/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillSearchDataSource : NSObject <UITableViewDataSource> {
	NSMutableArray* _rows;
	NSMutableData * _data;
	NSURLConnection *_activeConnection;
	IBOutlet UISearchDisplayController *searchDisplayController;
}
@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;

- (void)startSearchWithString:(NSString *)searchString chamber:(NSInteger)chamber;
- (id)initWithSearchDisplayController:(UISearchDisplayController *)newController;

@end

