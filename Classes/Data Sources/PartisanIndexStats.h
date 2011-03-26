//
//  PartisanIndexStats.h
//  TexLege
//
//  Created by Gregory Combs on 7/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "SynthesizeSingleton.h"

@class LegislatorObj;

@interface PartisanIndexStats : NSObject {
	//CGFloat	avgRepubHouseIndex, avgDemocHouseIndex, avgRepubSenateIndex, avgDemocSenateIndex;
	
@private
	NSDictionary *m_partisanIndexAggregates;	

}

@property (nonatomic, readonly) NSDictionary *partisanIndexAggregates;
@property (nonatomic, retain) NSString *chartTemplate;

+ (PartisanIndexStats *)sharedPartisanIndexStats;

- (CGFloat) minPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) maxPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) overallPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) partyPartisanIndexUsingChamber:(NSInteger)chamber andPartyID:(NSInteger)party;

- (NSArray *) historyForParty:(NSInteger)party Chamber:(NSInteger)chamber;

- (NSString *)partisanChartForLegislator:(LegislatorObj*)legislator width:(NSString *)width;
- (NSDictionary *)partisanshipDataForLegislatorID:(NSNumber*)legislatorID;

- (BOOL) resetChartCacheIfNecessary;

@end
