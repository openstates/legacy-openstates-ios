//
//  PartisanIndexStats.h
//  TexLege
//
//  Created by Gregory Combs on 7/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "Constants.h"

@class LegislatorObj;

@interface PartisanIndexStats : NSObject {
	IBOutlet NSManagedObjectContext *managedObjectContext;
	//CGFloat	avgRepubHouseIndex, avgDemocHouseIndex, avgRepubSenateIndex, avgDemocSenateIndex;
	
@private
	NSDictionary *m_partisanIndexAggregates;	

}

@property (nonatomic, readonly) NSDictionary *partisanIndexAggregates;
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSNumber *currentSessionYear;

+ (PartisanIndexStats *)sharedPartisanIndexStats;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

- (NSNumber *) minPartisanIndexUsingLegislator:(LegislatorObj *)legislator;
- (NSNumber *) maxPartisanIndexUsingLegislator:(LegislatorObj *)legislator;
	
- (NSString *) partisanRankForLegislator:(LegislatorObj *)legislator onlyParty:(BOOL)inParty;
- (NSNumber *) partyPartisanIndexUsingLegislator:(LegislatorObj *)legislator;
- (NSNumber *) overallPartisanIndexUsingLegislator:(LegislatorObj *)legislator;

- (NSDictionary *) historyForParty:(NSInteger)party Chamber:(NSInteger)chamber;
@end
