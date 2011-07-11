//
//  LegislatorContributionsDataSource.h
//  Created by Gregory Combs on 9/16/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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
