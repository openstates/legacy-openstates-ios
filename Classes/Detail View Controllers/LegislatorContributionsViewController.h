//
//  LegislatorContributionsViewController.h
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegislatorContributionsDataSource.h"

@interface LegislatorContributionsViewController : UITableViewController {

}
@property (nonatomic,retain) LegislatorContributionsDataSource *dataSource;
@property (nonatomic,copy) NSString *queryEntityID;
@property (nonatomic,copy) NSNumber *contributionQueryType;

- (void)setQueryEntityID:(NSString *)newObj withQueryType:(NSNumber *)newType;

@end
