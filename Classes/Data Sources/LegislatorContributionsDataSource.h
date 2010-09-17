//
//  LegislatorContributionsDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 9/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ContributionQueryType {
	kContributionQueryRecipient	= 0,
	kContributionQueryTop20Contributors,
	kContributionQueryDonor,
	kContributionTotal			= 997,
} ContributionQueryType;

#define kContributionsDataChangeNotificationKey @"ContributionsDataChangedKey"

@interface LegislatorContributionsDataSource : NSObject <UITableViewDataSource> {

}
@property (nonatomic,copy) NSString *queryEntityID;
@property (nonatomic,copy) NSNumber * contributionQueryType;
@property (nonatomic,retain) NSMutableArray *sectionList;

@property (nonatomic,retain) NSURLConnection *urlConnection;
@property (nonatomic,retain) NSMutableData *receivedData;

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) indexPathForDataObject:(id)dataObject;
- (NSString *)title;

@end
