//
//  LegislatorContributionsViewController.h
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegislatorContributionsDataSource.h"

@interface LegislatorContributionsViewController : UITableViewController <UIAlertViewDelegate> {

}
@property (nonatomic,retain) LegislatorContributionsDataSource *dataSource;

- (void)setQueryEntityID:(NSString *)newObj type:(NSNumber *)newType cycle:(NSString *)newCycle;

@end
