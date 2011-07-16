//
//  StateMetadataLoader.h
//  Created by Gregory Combs on 6/10/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

#define kStateMetaFile				@"StateMetadata.json"
#define kStateMetaPath				@"StateMetadata"
#define kStateMetaNotifyError		@"STATE_METADATA_ERROR"
#define kStateMetaNotifyStateLoaded		@"STATE_METADATA_STATE_LOADED"
#define kStateMetaNotifySessionChange	@"STATE_METADATA_SESSION_CHANGE"


@interface StateMetaLoader : NSObject <RKRequestDelegate> {
	NSMutableDictionary *_metadata;
	NSMutableArray *_loadingStates;
	BOOL isFresh;
	NSDate *updated;
	
	NSString *_selectedState;
	NSString *_selectedSession;
	NSMutableArray *_sessions;
}

+ (id)sharedStateMeta;	// Singleton

// Oftentimes, we just need a quick and dirty answer from our singleton
+ (NSString *)nameForChamber:(NSInteger)chamber;


- (void)loadMetadataForState:(NSString *)stateID;

@property (nonatomic) BOOL isFresh;

@property (nonatomic,copy) NSString *selectedState;

@property (nonatomic,copy) NSString *selectedSession;
@property (nonatomic,readonly) NSArray *sessions;
@property (nonatomic,readonly) NSString *latestSession;

@property (nonatomic,readonly) NSDictionary *stateMetadata;

@end
#define kMetaSelectedStateKey		@"selected_state"
#define kMetaSelectedSessionKey		@"selected_session"
#define kMetaSelectedStateSessionKey		@"selected_state_session"

#define kMetaLowerChamberNameKey @"lower_chamber_name"			// House of Representatives
#define kMetaUpperChamberNameKey @"upper_chamber_name"			// Senate
#define kMetaLowerChamberTitleKey @"lower_chamber_title"		// Representative
#define kMetaUpperChamberTitleKey @"upper_chamber_title"		// Senator
#define kMetaSessionsDetailsKey @"session_details"				// "811":{"type": "special","start_date": "2009-07-01 00:00:00", "end_date": "2009-07-10 00:00:00"}
#define kMetaSessionsKey @"sessions"		
#define kMetaSessionTermsKey @"terms"		
#define kMetaStateAbbrevKey @"abbreviation"						// tx
#define kMetaStateNameKey @"name"								// Texas
#define kMetaLowerChamberElectionTermKey @"lower_chamber_term"	// 2	[years/integer]
#define kMetaUpperChamberElectionTermKey @"upper_chamber_term"	// 4	[years/integer] 
