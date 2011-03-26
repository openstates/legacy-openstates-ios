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
@private
	NSDictionary *m_partisanIndexAggregates;	

}

@property (nonatomic, readonly) NSDictionary *partisanIndexAggregates;

+ (PartisanIndexStats *)sharedPartisanIndexStats;

- (CGFloat) minPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) maxPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) overallPartisanIndexUsingChamber:(NSInteger)chamber;
- (CGFloat) partyPartisanIndexUsingChamber:(NSInteger)chamber andPartyID:(NSInteger)party;

- (NSArray *) historyForParty:(NSInteger)party Chamber:(NSInteger)chamber;

- (NSDictionary *)partisanshipDataForLegislatorID:(NSNumber*)legislatorID;

@end
