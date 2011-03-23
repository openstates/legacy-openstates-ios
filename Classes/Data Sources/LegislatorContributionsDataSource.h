//
//  LegislatorContributionsDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 9/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

enum ContributionQueryType {
	kContributionQueryRecipient	= 0,
	kContributionQueryDonor,
	kContributionQueryIndividual,
	kContributionQueryTop10Donors,
	kContributionQueryTop10Recipients,
	kContributionQueryTop10RecipientsIndiv,
	kContributionQueryEntitySearch,
} ContributionQueryType;

#define kContributionsDataNotifyLoaded	@"ContributionsDataChangedKey"
#define kContributionsDataNotifyError	@"ContributionsDataErrorKey"

@interface LegislatorContributionsDataSource : NSObject <RKRequestDelegate, UITableViewDataSource> {

}
@property (nonatomic,copy) NSString *queryCycle;
@property (nonatomic,copy) NSString *queryEntityID;
@property (nonatomic,copy) NSNumber * queryType;
@property (nonatomic,retain) NSMutableArray *sectionList;

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) indexPathForDataObject:(id)dataObject;
- (NSString *)title;

- (void)initiateQueryWithQueryID:(NSString *)aQuery type:(NSNumber *)type cycle:(NSString *)cycle;

@end
