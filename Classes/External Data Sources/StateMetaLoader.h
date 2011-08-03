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

#import <RestKit/RestKit.h>

@class SLFState;
@interface StateMetaLoader : NSObject <RKObjectLoaderDelegate> {
	NSString            * _selectedSession;
	NSMutableArray      * _sessions;
	NSMutableDictionary * _sessionDisplayNames;
    BOOL                  isLoading;
}



@property (nonatomic)           BOOL          needsStateSelection;          // will be TRUE if the user hasn't selected a state before
@property (nonatomic)           BOOL          isFresh;
@property (nonatomic,retain)    NSDate      * updated;

@property (nonatomic,copy)      NSString    * selectedSession;
@property (nonatomic,readonly)  NSArray     * sessions;
@property (nonatomic,readonly)  NSDictionary* sessionDisplayNames;
@property (nonatomic,readonly)  NSString    * latestSession;

@property (nonatomic,copy)    NSArray         *defaultFeatures;
@property (nonatomic,copy)    NSArray         *features;
@property (nonatomic,retain)  SLFState        *selectedState;
@property (nonatomic,copy)    NSString        *resourcePath;
@property (nonatomic,assign)  Class            resourceClass;


+ (id)sharedStateMeta;	// Singleton
- (void)loadData;

- (id)initWithStateID:(NSString *)objID;
- (void)setSelectedStateWithID:(NSString *)stateID;

- (BOOL)isFeatureEnabled:(NSString *)feature;

@end


#define kMetaSelectedStateKey           @"selected_state"
#define kMetaSelectedSessionKey         @"selected_session"
#define kMetaSelectedStateSessionKey    @"selected_state_session"

