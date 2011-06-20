//
//  StateMetadataLoader.h
//  TexLege
//
//  Created by Gregory Combs on 6/10/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

#define kStateMetaFile				@"StateMetadata.json"
#define kStateMetaPath				@"StateMetadata"
#define kStateMetaNotifyError		@"STATE_METADATA_ERROR"
#define kStateMetaNotifyLoaded		@"STATE_METADATA_LOADED"


@interface StateMetaLoader : NSObject <RKRequestDelegate> {
	NSMutableDictionary *_metadata;
	BOOL isFresh;
	NSDate *updated;
	
	NSString *_selectedState;
	NSString *_currentSession;
}

+ (id)sharedStateMeta;	// Singleton

// Oftentimes, we just need a quick and dirty answer from our singleton
+ (NSString *)nameForChamber:(NSInteger)chamber;


- (void)loadMetadataForState:(NSString *)stateID;

@property (nonatomic) BOOL isFresh;

@property (nonatomic,copy) NSString *selectedState;
@property (nonatomic,readonly) NSString *currentSession;
@property (nonatomic,readonly) NSDictionary *stateMetadata;

@end
#define kMetaSelectedStateKey		@"selected_state"

#define kMetaLowerChamberNameKey @"lower_chamber_name"			// House of Representatives
#define kMetaUpperChamberNameKey @"upper_chamber_name"			// Senate
#define kMetaLowerChamberTitleKey @"lower_chamber_title"		// Representative
#define kMetaUpperChamberTitleKey @"upper_chamber_title"		// Senator
#define kMetaSessionsKey @"session_details"						// "811":{"type": "special","start_date": "2009-07-01 00:00:00", "end_date": "2009-07-10 00:00:00"}
#define kMetaSessionsAltKey @"terms"		
#define kMetaStateAbbrevKey @"abbreviation"						// tx
#define kMetaStateNameKey @"name"								// Texas
#define kMetaLowerChamberElectionTermKey @"lower_chamber_term"	// 2	[years/integer]
#define kMetaUpperChamberElectionTermKey @"upper_chamber_term"	// 4	[years/integer] 
