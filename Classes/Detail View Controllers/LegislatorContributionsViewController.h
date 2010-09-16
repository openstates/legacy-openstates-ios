//
//  LegislatorContributionsViewController.h
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;

@interface LegislatorContributionsViewController : UITableViewController{

}
@property (nonatomic,retain) NSMutableArray *topContributors;
@property (nonatomic,retain) LegislatorObj *legislator;
@property (nonatomic,retain) NSURLConnection *urlConnection;
@property (nonatomic,retain) NSMutableData *receivedData;
@end
