//
//  PartisanIndexStats.h
//  TexLege
//
//  Created by Gregory Combs on 7/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import <RestKit/RestKit.h>

#define kPartisanIndexNotifyError	@"PARTISAN_INDEX_ERROR"
#define kPartisanIndexNotifyLoaded	@"PARTISAN_INDEX_LOADED"

@class LegislatorObj;

@interface PartisanIndexStats : NSObject <RKRequestDelegate> {	
@private
	NSDictionary *m_partisanIndexAggregates;	
	NSMutableArray *m_rawPartisanIndexAggregates;	
	BOOL isFresh;
	BOOL isLoading;
	NSDate *updated;
}

@property (nonatomic, readonly) NSDictionary *partisanIndexAggregates;
@property (nonatomic) BOOL isFresh;

+ (PartisanIndexStats *)sharedPartisanIndexStats;
- (void)loadPartisanIndex:(id)sender;

- (CGFloat) minPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) maxPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) overallPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) partyPartisanIndexUsingChamber:(NSInteger)chamber andPartyID:(NSInteger)party;

- (NSArray *) historyForParty:(NSInteger)party chamber:(NSInteger)chamber;

- (NSDictionary *)partisanshipDataForLegislatorID:(NSNumber*)legislatorID;

@end
