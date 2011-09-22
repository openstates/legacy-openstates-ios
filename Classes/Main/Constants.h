//
//  Constants.h
//  Created by Gregory Combs on 7/13/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

extern NSString * const kSegmentControlPrefKey;
extern NSString * const kSupportEmailKey;

enum TABBAR_ITEM_TAGS {
    TAB_LEGISLATOR,
    TAB_COMMITTEE,
    TAB_DISTRICTMAP,
    TAB_CALENDAR,
    TAB_BILL,
    TAB_LINK
};

#define kStateMetaNotifyError           @"STATE_METADATA_ERROR"
#define kStateMetaNotifyStateLoaded		@"STATE_METADATA_STATE_LOADED"
#define kStateMetaNotifySessionChange	@"STATE_METADATA_SESSION_CHANGE"
