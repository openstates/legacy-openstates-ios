//
//  ContributionsDataSource.h
//  Created by Gregory Combs on 9/16/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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

@interface ContributionsDataSource : NSObject <RKRequestDelegate, UITableViewDataSource>
@property (nonatomic,copy) NSString *queryCycle;
@property (nonatomic,copy) NSString *queryEntityID;
@property (nonatomic,copy) NSNumber * queryType;
@property (nonatomic,retain) NSMutableArray *sectionList;
@property (nonatomic,retain) NSDictionary *tableHeaderData;

- (id)dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
- (NSString *)title;

- (void)initiateQueryWithQueryID:(NSString *)aQuery type:(NSNumber *)type cycle:(NSString *)cycle;

@end
